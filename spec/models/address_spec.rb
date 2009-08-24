require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:address).id.should_not be_nil
  end

  it "should not save without associated addressable" do
    address = Factory(:address)
    address.addressable = nil
    address.save.should == false
  end

  it "should not save without a label" do
    address = Factory(:address)
    address.label = nil
    address.save.should == false
  end

  it "should not save a duplicate label per addressable" do
    address = Factory(:address)
    duplicate = Factory.build(:address)
    duplicate.addressable = address.addressable
    duplicate.label = address.label
    duplicate.save.should == false
  end

  it "should have may_create/update/destroy? that returns addressable.may_create?" do
    address = Factory(:address)
    address.addressable.stub!(:may_update?).and_return(true)
    address.may_create?(nil).should == true
    address.may_update?(nil).should == true
    address.may_destroy?(nil).should == true
    address.addressable.stub!(:may_update?).and_return(false)
    address.may_create?(nil).should == false
    address.may_update?(nil).should == false
    address.may_destroy?(nil).should == false
  end

  it "should have may_see? that returns addressable.may_see?" do
    address = Factory(:address)
    address.addressable.stub!(:may_see?).and_return(true)
    address.may_see?(nil).should == true
    address.addressable.stub!(:may_see?).and_return(false)
    address.may_see?(nil).should == false
  end
end

