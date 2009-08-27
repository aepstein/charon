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

end

