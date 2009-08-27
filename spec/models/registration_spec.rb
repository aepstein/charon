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

  it "should have an eligible_for? that queries a framework and determines eligibility correctly" do
    framework = Factory(:framework)
    registration = Factory(:registration)
    registration.registered = true
    framework.member_percentage = nil
    registration.eligible_for?(framework).should == true
    framework.member_percentage = 50
    framework.member_percentage_type = 'undergrads'
    registration.number_of_grads = 100
    registration.percent_members_of_type(framework.member_percentage_type).should < framework.member_percentage
    registration.eligible_for?(framework).should == false
    framework.member_percentage = 5
    framework.member_percentage_type = 'grads'
    registration.eligible_for?(framework).should == true
  end

end

