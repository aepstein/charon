require 'spec_helper'

describe Approval do

  let( :approval ) { build :approval }

  context 'validations' do

    it "should create a new instance given valid attributes" do
      approval.save!
    end

    it "should not save without a user" do
      approval.user = nil
      approval.save.should be_false
    end

    it "should not save without an approvable" do
      approval.approvable = nil
      approval.save.should be_false
    end

    it "should not save with a duplicate approvable" do
      approval.save!
      duplicate = build( :approval, :approvable => approval.approvable,
        :user => approval.user )
      duplicate.save.should be_false
    end

    it "should not save if the approvable has changed after as_of" do
      approval.as_of = ( approval.approvable.updated_at - 2.minutes ).to_i
      approval.save.should be_false
    end

  end

  it "should have agreeements named scope that returns only agreements" do
    fund_request_approval = create(:approval, {:approvable => create(:approvable_fund_request)})
    agreement_approval = create(:approval, {:approvable => create(:agreement)})
    approvals = Approval.agreements
    approvals.should include( agreement_approval )
    approvals.should_not include( fund_request_approval )
    approvals.size.should eql 1
  end

  it "should call deliver_approval_notice on create" do
    approval.should_receive(:deliver_approval_notice)
    approval.save!
  end

  it "should call deliver_unapproval_notice on destroy" do
    approval.should_receive(:deliver_unapproval_notice)
    approval.destroy
  end

end

