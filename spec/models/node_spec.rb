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

  it "should have may_create? that returns structure.may_update?" do
    node = Factory.build(:node)
    node.structure.stub!(:may_update?).and_return('may_update')
    node.may_create?(nil).should == 'may_update'
  end

  it "should have may_update? that returns structure.may_update?" do
    node = Factory(:node)
    node.structure.stub!(:may_update?).and_return('may_update')
    node.may_update?(nil).should == 'may_update'
  end

  it "should have may_destroy? that returns structure.may_update?" do
    node = Factory(:node)
    node.structure.stub!(:may_update?).and_return('may_update')
    node.may_destroy?(nil).should == 'may_update'
  end

  it "should have a may_see? that returns structure.may_see?" do
    node = Factory(:node)
    node.structure.stub!(:may_see?).and_return('may_see')
    node.may_see?(nil).should == 'may_see'
  end

end

