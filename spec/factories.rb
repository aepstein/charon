Factory.define :organization do |f|
  f.sequence(:last_name) { |n| "Organization #{n}"}
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
  f.password_confirmation "pjlmiok"
end

Factory.define :structure do |f|
  f.sequence(:name) { |n| "Structure #{n}" }
  f.kind 'safc'
end

Factory.define :node do |f|
  f.requestable_type "AdministrativeExpense"
  f.name "administrative expense"
  f.association :structure
end

Factory.define :basis do |f|
  f.sequence(:name) { |n| "Basis #{n}" }
  f.association :structure
  f.open_at DateTime.now - 1.days
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
  #f.association :item, :factory => :item
end

Factory.define :stage do |f|
  f.sequence(:name) { |n| "Stage #{n}" }
end

Factory.define :administrative_expense do |f|
  f.copies 100
  f.repairs_restocking 100
  f.mailbox_wsh 25
end

