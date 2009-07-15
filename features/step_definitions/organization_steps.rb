Given /there is an open basis/ do
  b = Factory(:basis)
  b.open_at = DateTime.now - 2.days
  b.closed_at = DateTime.now + 2.days
end

Given /the following registered organizations/ do |organizations|
  organizations.hashes.each do |organization|
    org = Factory.build(:organization, organization)
    registration = Factory( :registration,
                            { :registered => true,
                              :number_of_undergrads => 60,
                              :name => org.last_name })
    registration.active?.should == true
    registration.safc_eligible?.should == true
    org.registrations << registration
    org.save.should == true
    org.safc_eligible?.should == true
  end
end

