require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Node do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:node).id.should_not be_nil
  end

  it "should not validate with an invalid requestable_type" do
    requestable_type = 'invalid'
    Node::ALLOWED_TYPES.should_not include(requestable_type)
    node = Factory.build(:node, { :requestable_type => requestable_type })
    node.valid?.should == false
  end
end

