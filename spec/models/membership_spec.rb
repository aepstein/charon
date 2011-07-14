require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    create(:membership).id.should_not be_nil
  end

  it "should not save without a role" do
    membership = create(:membership)
    membership.role = nil
    membership.save.should == false
  end

  it "should not save without a user" do
    membership = create(:membership)
    membership.user = nil
    membership.save.should == false
  end

  it "should not save without an organization or a registration" do
    membership = create(:membership)
    membership.organization = nil
    membership.registration = nil
    membership.save.should == false
  end
end

