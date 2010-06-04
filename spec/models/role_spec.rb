require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:role).id.should_not be_nil
  end

  it "should not save without a name" do
    role = Factory(:role)
    role.name = nil
    role.save.should == false
  end

  it "should not save with a non-unique name" do
    role = Factory(:role, :name => 'generic')
    duplicate_role = Factory.build(:role, :name => 'generic')
    duplicate_role.save.should == false
  end

  it 'should save permissions correctly' do
    role = Factory(:role)
    role.permissions.should be_empty
    role.permissions = ['manager']
    role.save
    role.permissions.should include 'manager'
    role.permissions.length.should eql 1
  end

end

