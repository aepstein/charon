require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })
  end

  it "should create a new instance given valid attributes" do
    Factory(:organization).new_record?.should == false
  end

  it "should be safc_eligible if given a safc-eligible, active registration" do
    @registered_organization.registrations.first.update_attributes( { :number_of_undergrads => 60 } )
    @registered_organization.registrations.first.safc_eligible?.should == true
    @registered_organization.registrations.first.active?.should == true
    @registered_organization.safc_eligible?.should == true
  end

  it "should be safc_eligible if given a gpsafc-eligible, active registration" do
    registration = Factory(:registration)
    @registered_organization.registrations.first.update_attributes( { :number_of_grads => 40 } )
    @registered_organization.registrations.first.gpsafc_eligible?.should == true
    @registered_organization.registrations.first.active?.should == true
    @registered_organization.gpsafc_eligible?.should == true
  end

  it "should have a requests.started method that returns draft requests" do
    request = Factory.build(:request)
    request.organizations << @registered_organization
    request.save
    @registered_organization.requests << request
    @registered_organization.requests.first.status = "draft"
    @registered_organization.requests.draft.empty?.should == false
  end

  it "should have a requests.creatable method that returns requests that can be made" do
  end

  it "should have a requests.released method that returns released requests" do
  end
end

