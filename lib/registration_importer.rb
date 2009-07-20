module RegistrationImporter

  ATTR_MAP = {  # old column names        # new column names
                :org_id =>                    :id,
                :org_name =>                  :name,
                :org_purpose =>               :purpose,
                :org_univ =>                  :independent,
                :registration_approved =>     :registered,
                :funding =>                   :funding_sources,
                :undergrad_membership =>      :number_of_undergrads,
                :grad_membership =>           :number_of_grads,
                :faculty_membership =>        :number_of_faculty,
                :staff_membership =>          :number_of_staff,
                :alumni_membership =>         :number_of_alumni,
                :noncornell_membership =>     :number_of_others,
                :org_email =>                 :org_email,
                :presidents_firstname =>      :pre_first_name,
                :presidents_lastname =>       :pre_last_name,
                :presidents_email =>          :pre_email,
                :presidents_netid =>          :pre_net_id,
                :vpresidents_firstname =>     :vpre_first_name,
                :vpresidents_lastname =>      :vpre_last_name,
                :vpresidents_email =>         :vpre_email,
                :vpresidents_netid =>         :vpre_net_id,
                :treasurers_firstname =>      :tre_first_name,
                :treasurers_lastname =>       :tre_last_name,
                :treasurers_email =>          :tre_email,
                :treasurers_netid =>          :tre_net_id,
                :fourth_firstname =>          :officer_first_name,
                :fourth_lastname =>           :officer_last_name,
                :fourth_email =>              :officer_email,
                :fourth_netid =>              :officer_net_id,
                :advisors_firstname =>        :adv_first_name,
                :advisors_lastname =>         :adv_last_name,
                :advisors_email =>            :adv_email,
                :advisors_netid =>            :adv_net_id,
                :updaters_date_submission =>  :when_updated
              }

  class ExternalRegistration < ActiveRecord::Base
    establish_connection :external_registrations
    set_table_name "organizations"
    set_primary_key "org_id"
    default_scope :select => RegistrationImporter::ATTR_MAP.keys.join(', ')
    named_scope :importable, lambda {
      if Registration.maximum(RegistrationImporter::ATTR_MAP[:updaters_date_submission]) then
      { :conditions => [
          "updaters_date_submission > ?",
          Registration.maximum(RegistrationImporter::ATTR_MAP[:updaters_date_submission]) ] }
      else
      { }
      end.merge( { :order => :updaters_date_submission } )
    }

    def registration_approved
      read_attribute(:registration_approved) == 'Approved'
    end

    def org_univ
      read_attribute(:org_univ) == 'Independent'
    end

    def attributes_for_local
      out = Hash.new
      RegistrationImporter::ATTR_MAP.each_pair do |key, value|
        out[value] = send(key) if send("#{key}?")
      end
      out
    end

    # Returns number of records imported
    def self.import
      count = 0
      Registration.transaction do
        ExternalRegistration.importable.each do |external|
          registration = Registration.find_or_initialize_by_id( external.org_id )
          registration.attributes = external.attributes_for_local
          registration.save && count += 1 if registration.new_record? || registration.changed?
        end
      end
      count
    end

  end
end

