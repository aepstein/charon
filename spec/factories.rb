Factory.define :organization do |f|
  f.first_name ""
  f.sequence(:last_name) { |n| "Organization #{n}"}
end

Factory.define :user do |f|
  f.first_name "John"
  f.sequence(:last_name) { |n| "Doe #{n}"}
  f.sequence(:net_id) { |n| "zzz#{n}"}
  f.password "pjlmiok"
  f.password_confirmation "pjlmiok"
end

Factory.define :structure do |f|
  f.sequence(:name) { |n| "Structure #{n}" }
end

Factory.define :node do |f|
  f.requestable_type "AdministrativeExpense"
  f.association :structure, :factory => :structure
end

Factory.define :basis do |f|
  f.association :structure, :factory => :structure
  f.open_at DateTime.now
  f.closed_at DateTime.now + 10.days
end

Factory.define :request do |f|
  f.association :basis, :factory => :basis
end

Factory.define :item do |f|
  f.association :request, :factory => :request
  f.association :node, :factory => :node
end

Factory.define :version do |f|
  f.association :item, :factory => :item
end

Factory.define :stage do |f|
end

Factory.define :registration do |f|
  f.name 'Registered Organization'
end

Factory.define :registered_membership_condition do |f|
  f.membership_type 'undergrads'
  f.membership_percentage 50
end

