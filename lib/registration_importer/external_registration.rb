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

    establish_connection :external_registrations
    set_table_name "orgs"
    set_primary_keys :org_id, :term_id
    default_scope :select => MAP.keys.join(', ')

    named_scope :importable, lambda {
      max_registration = Registration.find(:first, :conditions => 'when_updated IS NOT NULL', :order => 'when_updated DESC')
      if max_registration then
      { :conditions => ["updated_time > ?", max_registration.when_updated.to_i ] }
      else
      { }
      end.merge( { :order => :updated_time, :include => [ :contacts ] } )
    }

    has_many :contacts, :class_name => 'ExternalContact', :foreign_key => [ :org_id, :term_id ] do
      def find_or_create_users
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
      users = source.contacts.users
      deletes = destination.memberships.reject { |m| users.include?( [m.role, m.user] ) }
      destination.memberships.delete deletes
      adds = users.reject { |u| destination.memberships.users.include?( u ) }
      adds.inject([]) do |memo, (role, user)|
        destination.memberships.create( :role => role, :user => user, :active => term.current )
      end
      return (deletes + adds).length > 0
    end

    # Returns number of records imported
    def self.import
      ExternalRegistration.importable.find_each do |source|
        destination = Registration.find_or_initialize_by_external_id_and_external_term_id( source.org_id, source.term_id )
        destination.attributes = source.import_attributes( REGISTRATION_ATTRIBUTES )
        destination.save
        source.import_contacts( destination )
      end
      ExternalTerm.all.each do |term|
        Registration.external_term_id_equals( term.term_id ).all(
          :conditions => ['registrations.external_id NOT IN (?)',term.registrations.map(&:org_id)] ).map(&:destroy)
      end
    end

  end

end

