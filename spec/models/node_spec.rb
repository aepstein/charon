require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Node do
  before(:each) do
    @node = Factory(:node)
  end

  it "should create a new instance given valid attributes" do
    @node.id.should_not be_nil
  end

  it 'should not save without a structure' do
    @node.structure = nil
    @node.save.should be_false
  end

  it 'should not save without a name' do
    @node.name = nil
    @node.save.should be_false
  end

  it "should not validate with an invalid requestable_type" do
    requestable_type = 'invalid'
    Node::ALLOWED_TYPES.should_not include(requestable_type)
    node = Factory.build(:node, { :requestable_type => requestable_type })
    node.valid?.should == false
  end

  it "should not save without a valid category" do
    node = Factory(:node)
    node.category = nil
    node.save.should == false
  end

  it 'should not save with a duplicate name for a certain structure' do
    duplicate = Factory(:node)
    duplicate.name = @node.name
    duplicate.structure = @node.structure
    duplicate.valid?.should be_false
  end

end

