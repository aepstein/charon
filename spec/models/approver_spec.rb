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
    Version::PERSPECTIVES.should_not include(approver.perspective)
    approver.save.should == false
  end
end

