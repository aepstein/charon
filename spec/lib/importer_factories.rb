require 'registration_importer'

module RegistrationImporter
  class WritableExternalRegistration < ActiveRecord::Base
    establish_connection "external_registrations_#{::Rails.env}".to_sym
    self.table_name = "orgs"
    self.primary_key = "fake_id"

    belongs_to :term, class_name: 'ExternalTerm', foreign_key: :term_id,
      primary_key: :term_id

    def id
      return nil if term_id.blank? || org_id.blank?
      "#{term_id}_#{org_id}"
    end
  end

  class WritableExternalContact < ActiveRecord::Base
    establish_connection "external_registrations_#{::Rails.env}".to_sym
    self.table_name = "orgs_contacts"
    self.primary_key = "fake_id"

#    def registration=(registration)
#      self.full_org_id = registration.id
#      registration(true)
#    end
    def full_org_id; (term_id && org_id) ? "#{term_id}_#{org_id}" : nil; end
    def full_org_id=(id)
      if id.blank? || id.split.length != 2
        self.term_id, self.org_id = nil, nil
#        registration(true)
        return nil
      end
      self.term_id, self.org_id = id.split('_').first, id.split('_').last
      id
    end
    def id; "#{term_id}_#{org_id}_#{read_attribute :contacttype}"; end
  end
end

FactoryGirl.define do
  factory :external_term, class: RegistrationImporter::ExternalTerm do
    sequence(:term_id) { |n| n }
    sequence(:term_sdescr) { |n| "ET #{n}" }
    sequence(:term_ldescr) { |n| "External term #{n}" }
    current 'YES'
  end

  factory :external_registration, class: RegistrationImporter::WritableExternalRegistration do
    sequence(:fake_id) { |n| n }
    association :term, factory: :external_term
    sequence(:org_id) { |n| n }
    sequence(:name) { |n| "External registration #{n}" }
    orgtype 'CIO'
    reg_approved 'YES'
    sports_club 'YES'
  end

  factory :external_contact, class: RegistrationImporter::WritableExternalContact do
    sequence(:fake_id) { |n| n }
#    association :registration, factory: :external_registration
    contacttype { RegistrationImporter::ExternalContact::ROLE_MAP.keys.first }
    after_build do |external_contact|
      if external_contact.org_id.blank? || external_contact.term_id.blank?
        registration = FactoryGirl.create(:external_registration)
        external_contact.org_id = registration.org_id
        external_contact.term_id = registration.term_id
      end
    end
  end
end

