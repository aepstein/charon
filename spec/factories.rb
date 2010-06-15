require 'factory_girl'

Factory.define :external_term, :class => RegistrationImporter::ExternalTerm do |f|
  f.sequence(:term_id) { |n| n }
  f.sequence(:term_sdescr) { |n| "ET #{n}" }
  f.sequence(:term_ldescr) { |n| "External term #{n}" }
  f.current 'YES'
end

Factory.define :external_registration, :class => RegistrationImporter::ExternalRegistration do |f|
  f.association :term, :factory => :external_term
  f.sequence(:name) { |n| "External registration #{n}" }
  f.orgtype 'CIO'
end

Factory.define :external_contact, :class => RegistrationImporter::ExternalContact do |f|
  f.association :organization, :factory => :external_registration
  f.term { |c| c.organization.term }
  f.contacttype RegistrationImporter::ExternalContact::ROLE_MAP.keys.first
end

Factory.define :address do |f|
  f.association :addressable, :factory => :user
  f.sequence(:label) { |n| "Address #{n}" }
end

Factory.define :agreement do |f|
  f.sequence(:name) { |n| "Agreement #{n}" }
  f.content "Text of an agreement"
  f.contact_name "a contact"
  f.contact_email "contact@example.com"
end

Factory.define :approval do |f|
  f.association :user
  f.association :approvable, :factory => :request
  f.as_of { |approval| approval.approvable.updated_at + 1.second }
end

Factory.define :approver do |f|
  f.association :framework
  f.association :role
  f.status 'submitted'
  f.perspective Edition::PERSPECTIVES.first
end

Factory.define :category do |f|
  f.sequence(:name) { |n| "Category #{n}" }
end

Factory.define :document do |f|
  f.attached { ActionController::TestUploadedFile.new('features/support/assets/small.png','image/png') }
  f.association :edition, :factory => :attachable_edition
  f.document_type { |d| d.edition.document_types.first }
end

Factory.define :document_type do |f|
  f.sequence(:name) { |n| "Document Type #{n}" }
  f.max_size_quantity 1
  f.max_size_unit DocumentType::UNITS.last
end

Factory.define :organization do |f|
  f.sequence(:last_name) { |n| "Organization #{n}"}
end

Factory.define :framework do |f|
  f.sequence(:name) { |n| "Sequence #{n}" }
end

Factory.define :fulfillment do |f|
  f.fulfiller { |r| r.association(:user) }
  f.fulfillable { |r| r.association(:agreement) }
end

Factory.define :safc_framework, :parent => :framework do |f|
  f.must_register true
  f.member_percentage 60
  f.member_percentage_type 'undergrads'
end

Factory.define :gpsafc_framework, :parent => :framework do |f|
  f.must_register true
  f.member_percentage 40
  f.member_percentage_type 'grads'
end

Factory.define :registration do |f|
  f.sequence(:name) { |n| "Registered Organization #{n}" }
  f.sequence(:external_id) { |i| i }
  f.number_of_undergrads 1
end

Factory.define :registration_criterion do |f|
  f.must_register true
  f.minimal_percentage 10
  f.type_of_member 'undergrads'
end

Factory.define :requirement do |f|
  f.association :framework
  f.fulfillable { |r| r.fulfillable = Factory(:agreement) }
end

Factory.define :safc_eligible_registration, :parent => :registration do |f|
  f.registered true
  f.number_of_undergrads 50
end

Factory.define :gpsafc_eligible_registration, :parent => :registration do |f|
  f.registered true
  f.number_of_grads 50
end

Factory.define :user do |f|
  f.first_name "John"
  f.sequence(:last_name) { |n| "Doe #{n}"}
  f.sequence(:net_id) { |n| "zzz#{n}"}
  f.password "secret"
  f.password_confirmation { |u| u.password }
  f.status "undergrad"
  f.ldap_entry false
end

Factory.define :user_status_criterion do |f|
  f.statuses [ 'undergrad' ]
end

Factory.define :role do |f|
  f.sequence(:name) { |n| "role #{n}" }
end

Factory.define :requestor_role, :parent => :role do |f|
  f.name Role::REQUESTOR.first
end

Factory.define :reviewer_role, :parent => :role do |f|
  f.name Role::REVIEWER.first
end

Factory.define :manager_role, :parent => :role do |f|
  f.name Role::MANAGER.first
end

Factory.define :membership do |f|
  f.active true
  f.association :user
  f.association :role
  f.association :organization
end

Factory.define :structure do |f|
  f.sequence(:name) { |n| "Structure #{n}" }
end

Factory.define :node do |f|
  f.sequence(:name) { |n| "node #{n}" }
  f.item_quantity_limit 1
  f.association :structure
  f.association :category
end

Factory.define :attachable_node, :parent => :node do |f|
  f.document_types { |node| [ node.association(:document_type) ] }
end

Factory.define :basis do |f|
  f.sequence(:name) { |n| "Basis #{n}" }
  f.association :organization
  f.association :framework
  f.association :structure
  f.open_at DateTime.now - 1.days
  f.closed_at DateTime.now + 10.days
  f.submissions_due_at { |b| b.closed_at - 1.days }
  f.contact_name "a contact"
  f.contact_email "contact@example.com"
  f.contact_web "http://example.com"
end

Factory.define :request do |f|
  f.association :basis
  f.association :organization
end

Factory.define :item do |f|
  f.association :request
  f.node { |item| item.association(:node, :structure => item.request.structure) }
end

Factory.define :attachable_item, :parent => :item do |f|
  f.association :request
  f.node { |item| item.association(:attachable_node, :structure => item.request.structure) }
end

Factory.define :edition do |f|
  f.amount 0.0
  f.perspective 'requestor'
  f.association :item
end

Node::ALLOWED_TYPES.each_value do |t|
  Factory.define "#{t}Node".underscore.to_sym, :parent => :node do |f|
    f.requestable_type t
  end
  Factory.define "#{t}Item".underscore.to_sym, :parent => :item do |f|
    f.association :request
    f.node { |item| item.association("#{t}Node".underscore.to_sym, :structure => item.request.structure) }
  end
  Factory.define "#{t}Edition".underscore.to_sym, :parent => :edition do |f|
    f.item { |edition| edition.association "#{t}Item".underscore.to_sym  }
  end
end

Factory.define :attachable_edition, :parent => :edition do |f|
  f.association :item, :factory => :attachable_item
end

Factory.define :administrative_expense do |f|
  f.association :edition, :factory => :administrative_expense_edition
  f.copies 100
  f.repairs_restocking 100
  f.mailbox_wsh 25
end

Factory.define :durable_good_expense do |f|
  f.association :edition, :factory => :durable_good_expense_edition
  f.description 'a durable good'
  f.quantity 1.5
  f.price 1.5
end

Factory.define :local_event_expense do |f|
  f.association :edition, :factory => :local_event_expense_edition
  f.date Date.today + 2.months
  f.title 'An Event'
  f.location 'Willard Straight Hall'
  f.purpose 'To do something fun'
  f.number_of_attendees 50
  f.price_per_attendee 5.50
  f.copies_quantity 500
  f.services_cost 1102
end

Factory.define :publication_expense do |f|
  f.association :edition, :factory => :publication_expense_edition
  f.title 'Publication'
  f.number_of_issues 3
  f.copies_per_issue 500
  f.price_per_copy 4.00
  f.cost_per_issue 2809.09
end

Factory.define :travel_event_expense do |f|
  f.association :edition, :factory => :travel_event_expense_edition
  f.date Date.today + 2.months
  f.title "A tournament"
  f.location 'Los Angeles, CA'
  f.purpose 'To compete'
  f.travelers_per_group 5
  f.number_of_groups 2
  f.distance 6388
  f.nights_of_lodging 3
  f.per_person_fees 25.00
  f.per_group_fees 125.00
end

Factory.define :speaker_expense do |f|
  f.association :edition, :factory => :speaker_expense_edition
  f.title 'An Important Person'
  f.distance 204
  f.number_of_travelers 1
  f.nights_of_lodging 10
  f.engagement_fee 1000
end

Factory.define :external_equity_report do |f|
  f.association :edition, :factory => :external_equity_report_edition
end

