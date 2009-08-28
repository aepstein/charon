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
end

Factory.define :approver do |f|
  f.association :framework
  f.association :role
  f.status 'submitted'
  f.perspective 'requestor'
end

Factory.define :document do |f|
  f.attached { ActionController::TestUploadedFile.new('features/support/assets/small.png','image/png') }
  f.association :version, :factory => :attachable_version
  f.document_type { |d| d.version.document_types.first }
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
  f.member_percentage nil
end

Factory.define :permission do |f|
  f.association :role
  f.association :framework
  f.perspective Version::PERSPECTIVES.first
  f.status Request.aasm_states.first.name.to_s
  f.action Request::ACTIONS.first
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
  f.password "pjlmiok"
  f.password_confirmation { |u| u.password }
  f.status "undergrad"
  f.ldap_entry false
end

Factory.define :role do |f|
  f.sequence(:name) { |n| "Role #{n}" }
end

Factory.define :membership do |f|
  f.active true
  f.association :user
  f.association :role
  f.association :organization
  f.association :registration
end

Factory.define :structure do |f|
  f.sequence(:name) { |n| "Structure #{n}" }
end

Factory.define :node do |f|
  f.requestable_type "AdministrativeExpense"
  f.sequence(:name) { |n| "administrative expense #{n}" }
  f.item_quantity_limit 1
  f.association :structure
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
  f.contact_name "a contact"
  f.contact_email "contact@example.com"
end

Factory.define :request do |f|
  f.association :basis
  f.organizations { |o| [ o.association(:organization) ] }
end

Factory.define :item do |f|
  f.association :request
  f.node { |item| item.association(:node, :structure => item.request.structure) }
end

Factory.define :attachable_item, :parent => :item do |f|
  f.association :request
  f.node { |item| item.association(:attachable_node, :structure => item.request.structure) }
end

Factory.define :version do |f|
  f.amount 0.0
  f.perspective 'requestor'
  f.association :item
end

Factory.define :attachable_version, :parent => :version do |f|
  f.association :item, :factory => :attachable_item
end

Factory.define :stage do |f|
  f.sequence(:name) { |n| "Stage #{n}" }
end

Factory.define :administrative_expense do |f|
  f.association :version
  f.copies 100
  f.repairs_restocking 100
  f.mailbox_wsh 25
end

Factory.define :durable_good_expense do |f|
  f.association :version
  f.description 'a durable good'
  f.quantity 1.5
  f.price 1.5
end

Factory.define :local_event_expense do |f|
  f.association :version
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
  f.association :version
  f.title 'Publication'
  f.number_of_issues 3
  f.copies_per_issue 500
  f.price_per_copy 4.00
  f.cost_per_issue 2809.09
end

Factory.define :travel_event_expense do |f|
  f.association :version
  f.event_date Date.today + 2.months
  f.event_title "A tournament"
  f.event_location 'Los Angeles, CA'
  f.event_purpose 'To compete'
  f.members_per_group 5
  f.number_of_groups 2
  f.mileage 6388
  f.nights_of_lodging 3
  f.per_person_fees 25.00
  f.per_group_fees 125.00
end

Factory.define :speaker_expense do |f|
  f.association :version
  f.speaker_name 'An Important Person'
  f.performance_date Date.today + 2.months
  f.mileage 204
  f.number_of_speakers 1
  f.nights_of_lodging 10
  f.engagement_fee 1000
  f.car_rental 100
end

