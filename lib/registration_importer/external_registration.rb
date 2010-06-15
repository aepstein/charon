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
        inject({}) do |memo, contact|
          memo[ contact.contacttype ] ||= Array.new
          memo[ contact.contacttype ] << contact.net_ids.inject( [] ) do |users, net_id|
            users << User.find_or_create_by_net_id( net_id, contact.import_attributes_for_user )
          end
        end
      end
    end
    belongs_to :term, :class_name => 'ExternalTerm', :foreign_key => [ :term_id ]

    def self.import_class; Registration; end

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

    # Returns number of records imported
    def self.import(registrations = nil)
      registrations ||= ExternalRegistration.importable
      count, destroy_count = 0, 0
      Registration.transaction do
        registrations.each do |external|
          registration = Registration.find_or_initialize_by_external_id( external.org_id, :external_term_id => external.term_id )
          registration.attributes = external.import_attributes
          registration.save
          external_contacts.find_or_create_users.inject([]) do |memberships, ( role, users )|
            users.each do |user|
              registration.memberships.find_or_create( :role => role, :user => user, :active => external.term )
            end
          end
          external.external_contacts.each do |contact|
            users = contact.net_ids.inject([]) do |memo, net_id|
              memo << User.find_or_create_by_net_id( net_id, contact.import_attributes_for_user )
            end
            users.inject([]) do |memo, user|
              registration.memberships.find_or_create( :user_id => user.id, :role_id =>  )
            end
          end

#          count += 1 if changed
        end
        ExternalTerm.all( :include => [ :external_registrations ] ).each do |term|
          Registration.external_term_id_equals( term.id ).all( :conditions => [
            'registrations.external_id NOT IN (?)',
            term.external_registrations.map(&:org_id) ] ).each do |registration|
            registration.destroy && destroy_count += 1
          end
        end
      end
      [count, destroy_count]
    end

  end

end

