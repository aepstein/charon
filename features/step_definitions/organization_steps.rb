Given /there is an open basis/ do
  b = Factory(:basis)
  b.open_at = DateTime.now - 2.days
  b.closed_at = DateTime.now + 2.days
end

Given /the following registered organizations:/ do |organizations|
  organizations.hashes.each do |organization|
    org = Factory.build(:organization, organization)
    org.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 60 })
    org.save
  end
end

