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

end

