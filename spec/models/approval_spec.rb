require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Approval do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:approval).id.should_not be_nil
  end

  it "should not save without a user" do
    approval = Factory(:approval)
    approval.user = nil
    approval.save.should == false
  end

  it "should not save without an approvable" do
    approval = Factory(:approval)
    approval.approvable = nil
    approval.save.should == false
  end

  it "should not save with a duplicate approvable" do
    original = Factory(:approval)
    duplicate = original.clone
    duplicate.save.should == false
  end

  it "should have a may_create? which returns approvable.may_approve?" do
    approval = Factory(:approval)
    approval.approvable.stub!(:may_approve?).and_return(true)
    approval.may_create?(nil).should == true
    approval.approvable.stub!(:may_approve?).and_return(false)
    approval.may_create?(nil).should == false
  end

  it "should have a may_destroy? which returns approvable.may_unapprove? for matching user otherwise may_unapprove_other?" do
    approval = Factory(:approval)
    other = Factory(:user)
    approval.approvable.stub!(:may_unapprove?).and_return(true)
    approval.may_destroy?(approval.user).should == true
    approval.approvable.stub!(:may_unapprove?).and_return(false)
    approval.may_destroy?(approval.user).should == false
    approval.approvable.stub!(:may_unapprove_other?).and_return(true)
    approval.may_destroy?(other).should == true
    approval.approvable.stub!(:may_unapprove_other?).and_return(false)
    approval.may_destroy?(other).should == false
  end

  it "should have agreeements named scope that returns only agreements" do
    request_approval = Factory(:approval, {:approvable => Factory(:request)})
    agreement_approval = Factory(:approval, {:approvable => Factory(:agreement)})
    approvals = Approval.agreements
    approvals.should include( agreement_approval )
    approvals.should_not include( request_approval )
    approvals.size.should == 1
  end
end
