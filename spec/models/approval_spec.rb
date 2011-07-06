require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Approval do
  before(:each) do
    @approval = Factory.build(:approval)
  end

  it "should create a new instance given valid attributes" do
    @approval.save.should == true
  end

  it "should not save without a user" do
    @approval.user = nil
    @approval.save.should == false
  end

  it "should not save without an approvable" do
    @approval.approvable = nil
    @approval.save.should == false
  end

  it "should not save with a duplicate approvable" do
    original = Factory(:approval)
    duplicate = original.clone
    duplicate.save.should == false
  end

  it "should not save if the approvable has changed after as_of" do
    @approval.as_of = @approval.approvable.updated_at - 2.minutes
    @approval.save.should == false
  end

  it "should have agreeements named scope that returns only agreements" do
    fund_request_approval = Factory(:approval, {:approvable => Factory(:fund_request)})
    agreement_approval = Factory(:approval, {:approvable => Factory(:agreement)})
    approvals = Approval.agreements
    approvals.should include( agreement_approval )
    approvals.should_not include( fund_request_approval )
    approvals.size.should == 1
  end

  it "should call deliver_approval_notice on create" do
    approval = Factory.build(:approval)
    approval.should_receive(:deliver_approval_notice)
    approval.save.should be_true
  end

  it "should call deliver_unapproval_notice on destroy" do
    approval = Factory(:approval)
    approval.should_receive(:deliver_unapproval_notice)
    approval.destroy
  end

  it 'should fulfill agreement for the user on create' do
    user = Factory(:user)
    agreement = Factory(:agreement)
    approval = Factory(:approval, :user => user, :approvable => agreement)
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql agreement
    approval.destroy
    user.fulfillments(true).size.should eql 0
  end
end

