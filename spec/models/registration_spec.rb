require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registration do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:registration).new_record?.should == false
  end

  it "should calculate percent_members_of_type correctly" do
    factory = Factory(:registration)
    factory.number_of_undergrads = 60
    factory.percent_members_of_type(:undergrads).should == 100.0
  end

  it "should be able to create an organization from the registration" do
    registration = Factory(:registration)
    organization = registration.find_or_create_organization
    organization.id.should_not be_nil
    organization.registrations << registration
    registration.organization_id.should == organization.id
    registration.find_or_create_organization.should == organization
  end

  it 'should fulfill/unfulfill related organizations on create/update' do
    criterion1 = Factory(:registration_criterion, :minimal_percentage => 50,
      :type_of_member => 'undergrads', :must_register => true)
    criterion2 = Factory(:registration_criterion, :minimal_percentage => 50,
      :type_of_member => 'undergrads', :must_register => false)
    criterion3 = Factory(:registration_criterion, :minimal_percentage => 50,
      :type_of_member => 'others', :must_register => false)
    registration = Factory(:current_registration,
      :organization => Factory(:organization), :number_of_undergrads => 10,
      :registered => true )
    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
    fulfillables.size.should eql 2
    fulfillables.should include criterion1
    fulfillables.should include criterion2
    registration.registered = false
    registration.save!
    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
    fulfillables.length.should eql 1
    fulfillables.should include criterion2
    registration.number_of_others = 11
    registration.save!
    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
    fulfillables.length.should eql 1
    fulfillables.should include criterion3
  end

end

