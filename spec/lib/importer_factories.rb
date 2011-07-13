FactoryGirl.define do
  factory :external_term, :class => RegistrationImporter::ExternalTerm do
    sequence(:term_id) { |n| n }
    sequence(:term_sdescr) { |n| "ET #{n}" }
    sequence(:term_ldescr) { |n| "External term #{n}" }
    current 'YES'
  end

  factory :external_registration, :class => RegistrationImporter::ExternalRegistration do
    association :term, :factory => :external_term
    sequence(:org_id) { |n| n }
    sequence(:name) { |n| "External registration #{n}" }
    orgtype 'CIO'
    reg_approved 'YES'
    sports_club 'YES'
  end

  factory :external_contact, :class => RegistrationImporter::ExternalContact do
    association :registration, :factory => :external_registration
    contacttype { RegistrationImporter::ExternalContact::ROLE_MAP.keys.first }
  end
end

