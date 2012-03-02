module RegistrationImporter
  class ExternalRegistration < ActiveRecord::Base

    include RegistrationImporter

    MAP = {
      # old column names     => new column names
      :org_id                => :external_id,
      :term_id               => :external_term_id,
      :name                  => :name,
      :purpose               => :purpose,
      :orgtype               => :independent,
      :reg_approved          => :registered,
      :sports_club           => :sports_club,
      :funding               => :funding_sources,
      :membership_ugrad      => :number_of_undergrads,
      :membership_grad       => :number_of_grads,
      :membership_faculty    => :number_of_faculty,
      :membership_staff      => :number_of_staff,
      :membership_alumni     => :number_of_alumni,
      :membership_noncornell => :number_of_others,
      :updated_time          => :when_updated
    }
    REGISTRATION_ATTRIBUTES = [ :name, :purpose, :orgtype, :reg_approved, :sports_club,
      :funding, :membership_ugrad, :membership_grad, :membership_faculty,
      :membership_staff, :membership_alumni, :membership_noncornell, :updated_time ]

    establish_connection "external_registrations_#{::Rails.env}".to_sym
    self.table_name = "orgs"
    self.primary_keys = [ :org_id, :term_id ]
    default_scope select( MAP.keys.join(', ') ).order( 'orgs.updated_time ASC' )

    scope :importable, lambda {
      max_registration = Registration.unscoped.
        where( Registration.arel_table[:when_updated].not_eq( nil ) ).
        maximum(:when_updated)
      if max_registration then
        where( :updated_time.gt => max_registration )
      else
        scoped
      end
    }

    belongs_to :term, :class_name => 'ExternalTerm', :foreign_key => :term_id

    def contacts(reset=false)
      @contacts = nil if reset
      @contacts ||= ExternalContact.where( :org_id => org_id, :term_id => term_id )
    end

    def contacts_users(reset=false)
      @contacts_users = nil if reset
      @contacts_users ||= contacts(reset).map(&:users).reduce([],&:+).uniq
    end

    def reg_approved
      read_attribute(:reg_approved) == 'YES'
    end

    def funding
      return [] unless funding?
      read_attribute(:funding).downcase.split(',')
    end

    def orgtype
      read_attribute(:orgtype) == 'CIO'
    end

    def sports_club
      read_attribute(:sports_club) == 'YES'
    end

    def import
      destination = Registration.find_or_initialize_by_external_id_and_external_term_id(
        org_id, term_id )
      import_attributes( REGISTRATION_ATTRIBUTES ).each do |k,v|
        destination.send "#{k}=", v
      end
      out = Array.new
      out << ( destination.new_record? ? 1 : 0  )
      out << ( destination.changed? ? 1 : 0 )
      destination.save if out.last == 1
      out[1] = 1 if import_contacts( destination )
      out
    end

    def import_contacts( destination )
      deletes = destination.memberships.reject { |m| contacts_users.include?( [m.role, m.user] ) }
      destination.memberships.delete( deletes ) unless deletes.empty?
      adds = contacts_users.reject { |u| destination.memberships.users.include? u }
      adds.each do |pair|
        m = destination.memberships.build
        m.role = pair.first
        m.user = pair.last
        m.save
      end
      return (deletes + adds).length > 0
    end

    # Returns array of information about records affected by update
    def self.import( set = :latest )
      adds, changes, deletes, starts = 0, 0, 0, Time.now
      ExternalTerm.all.each do |term|
        registrations = case set
        when :latest
          term.registrations.latest
        else
          term.registrations
        end
        registrations.all.each do |source|
          r = source.import
          adds += r.first
          changes += r.last
        end
        d = Registration.unscoped.where( :external_term_id => term.term_id )
        if term.registrations.length > 0
          d = d.where( 'registrations.external_id NOT IN (?)', term.registrations.map(&:org_id) )
        end
        deletes = d.all.map(&:destroy).length
      end
      [adds, (changes - adds), deletes, ( Time.now - starts )]
    end

  end

end

