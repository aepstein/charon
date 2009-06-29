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

Factory.define :basis do |f|
  f.association :structure, :factory => :structure
  f.open_at DateTime.now
  f.closed_at DateTime.now + 10.days
end

Factory.define :structure do |f|
  f.sequence(:name) { |n| "Structure #{n}" }
end

