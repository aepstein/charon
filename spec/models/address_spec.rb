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

end

