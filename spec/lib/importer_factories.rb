Factory.define :external_term, :class => RegistrationImporter::ExternalTerm do |f|
  f.sequence(:term_id) { |n| n }
  f.sequence(:term_sdescr) { |n| "ET #{n}" }
  f.sequence(:term_ldescr) { |n| "External term #{n}" }
  f.current 'YES'
end

Factory.define :external_registration, :class => RegistrationImporter::ExternalRegistration do |f|
  f.association :term, :factory => :external_term
  f.sequence(:org_id) { |n| n }
  f.sequence(:name) { |n| "External registration #{n}" }
  f.orgtype 'CIO'
  f.reg_approved 'YES'
  f.sports_club 'YES'
end

Factory.define :external_contact, :class => RegistrationImporter::ExternalContact do |f|
  f.association :registration, :factory => :external_registration
  f.contacttype RegistrationImporter::ExternalContact::ROLE_MAP.keys.first
end

