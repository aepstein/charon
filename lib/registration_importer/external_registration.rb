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
      end.merge( { :order => :updated_time, :include => [ :external_contacts ] } )
    }

    has_many :external_contacts, :class_name => 'ExternalContact', :foreign_key => [ :org_id, :term_id ]
    belongs_to :external_term, :class_name => 'ExternalTerm', :foreign_key => [ :term_id ]

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
          registration = Registration.find_or_initialize_by_external_id( external.org_id, external.term_id )
          registration.attributes = external.import_attributes_for_local
          registration.save && count += 1 if registration.changed?
        end
        ExternalTerm.each do |term|
          Registration.external_term_id_equals( term.id ).all( :conditions => [
            'registrations.external_id NOT IN (?)',
            ExternalRegistration.term_id_equals( term.id ).map(&:org_id) ] ).each do |registration|
            registration.destroy && destroy_count += 1
          end
        end
      end
      [count, destroy_count]
    end

  end

end

