require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:organization).new_record?.should == false
  end

  it "should be safc_eligible if given a safc-eligible, active registration" do
    registration = Factory(:registration)
    registration.update_attributes( { :registered => true, :number_of_undergrads => 60 } )
    registration.safc_eligible?.should == true
    registration.active?.should == true
    organization = Factory(:organization)
    organization.registrations << registration
    organization.safc_eligible?.should == true
  end

  it "should be safc_eligible if given a gpsafc-eligible, active registration" do
    registration = Factory(:registration)
    registration.update_attributes( { :registered => true, :number_of_grads => 40 } )
    registration.gpsafc_eligible?.should == true
    registration.active?.should == true
    organization = Factory(:organization)
    organization.registrations << registration
    organization.gpsafc_eligible?.should == true
  end
end

