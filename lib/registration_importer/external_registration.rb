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
      :funding               => :funding_sources,
      :membership_ugrad      => :number_of_undergrads,
      :membership_grad       => :number_of_grads,
      :membership_faculty    => :number_of_faculty,
      :membership_staff      => :number_of_staff,
      :membership_alumni     => :number_of_alumni,
      :membership_noncornell => :number_of_others,
      :updated_time          => :when_updated
    }
    REGISTRATION_ATTRIBUTES = [ :name, :purpose, :orgtype, :reg_approved, :funding,
      :membership_ugrad, :membership_grad, :membership_faculty, :membership_staff,
      :membership_alumni, :membership_noncornell, :updated_time ]

    establish_connection "external_registrations_#{RAILS_ENV}".to_sym
    set_table_name "orgs"
    set_primary_keys :org_id, :term_id
    default_scope :select => MAP.keys.join(', '), :include => [ :contacts ]

    named_scope :importable, lambda {
      max_registration = Registration.find(:first, :conditions => 'when_updated IS NOT NULL', :order => 'when_updated DESC')
      if max_registration then
      { :conditions => ["updated_time > ?", max_registration.when_updated.to_i ] }
      else
      { }
      end.merge( { :order => :updated_time, :include => [ :contacts ] } )
    }

    has_many :contacts, :class_name => 'ExternalContact', :foreign_key => [ :org_id, :term_id ] do
      def users
        m = self.inject([]) do |memo, contact|
          contact.net_ids.inject(memo) do |memberships, net_id|
            memberships << [ contact.contacttype,
              User.find_or_create_by_net_id( net_id, contact.import_attributes(
                RegistrationImporter::ExternalContact::USER_ATTRIBUTES ) ) ]
          end
        end
        m.uniq
      end
    end
    belongs_to :term, :class_name => 'ExternalTerm', :foreign_key => [ :term_id ]

    def registration_approved
      read_attribute(:reg_approved) == 'Yes'
    end

    def funding
      read_attribute(:funding).downcase.split(',')
    end

    def orgtype
      read_attribute(:orgtype) == 'CIO'
    end

    def updated_time
      Time.zone.at read_attribute(:updated_time)
    end

    def import_contacts( destination )
      deletes = destination.memberships.reject { |m| contacts.users.include?( [m.role, m.user] ) }
      destination.memberships.delete deletes
      adds = contacts.users.reject { |u| destination.memberships.users.include?( u ) }
      adds.inject([]) do |memo, (role, user)|
        destination.memberships.create( :role => role, :user => user, :active => term.current? )
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
        registrations.ascend_by_updated_time.all.each do |source|
          destination = Registration.find_or_initialize_by_external_id_and_external_term_id( source.org_id, source.term_id )
          destination.attributes = source.import_attributes( REGISTRATION_ATTRIBUTES )
          changed = destination.changed?
          adds += 1 if destination.new_record?
          destination.save if changed
          changes += 1 if source.import_contacts( destination ) || changed
        end
        deletes += Registration.external_term_id_equals( term.term_id ).all(
          :conditions => ['registrations.external_id NOT IN (?)',term.registrations.map(&:org_id)] ).map(&:destroy).length
      end
      [adds, (changes - adds), deletes, ( Time.now - starts )]
    end

  end

end

