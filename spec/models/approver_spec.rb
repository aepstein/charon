require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Approver do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:approver).id.should_not be_nil
  end

  it "should not save without framework" do
    approver = Factory(:approver)
    approver.framework = nil
    approver.save.should == false
  end

  it "should not save without role" do
    approver = Factory(:approver)
    approver.role = nil
    approver.save.should == false
  end

  it "should not save with invalid status" do
    approver = Factory(:approver)
    approver.status = 'invalid'
    Request.aasm_state_names.should_not include(approver.status)
    approver.save.should == false
  end

  it "should not save with invalid perspective" do
    approver = Factory(:approver)
    approver.perspective = 'invalid'
    Edition::PERSPECTIVES.should_not include(approver.perspective)
    approver.save.should == false
  end

  it "should not save duplicate approvers" do
    original = Factory(:approver)
    second = original.clone
    second.save.should == false
  end

  it "should have may_create? that returns framework.may_update?" do
    approver = Factory.build(:approver)
    approver.framework.stub!(:may_update?).and_return('may_update')
    approver.may_create?(nil).should == 'may_update'
  end

  it "should have may_update? that returns framework.may_update?" do
    approver = Factory(:approver)
    approver.framework.stub!(:may_update?).and_return('may_update')
    approver.may_update?(nil).should == 'may_update'
  end

  it "should have may_destroy? that returns framework.may_update?" do
    approver = Factory(:approver)
    approver.framework.stub!(:may_update?).and_return('may_update')
    approver.may_destroy?(nil).should == 'may_update'
  end

  it "should have a may_see? that returns framework.may_see?" do
    approver = Factory(:approver)
    approver.framework.stub!(:may_see?).and_return('may_see')
    approver.may_see?(nil).should == 'may_see'
  end
end

