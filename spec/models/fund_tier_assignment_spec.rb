require 'spec_helper'

describe FundTierAssignment do
  let(:fund_tier_assignment) { build(:fund_tier_assignment) }

  context "validation" do
    it "should save with valid attributes" do
      fund_tier_assignment.save!
    end

    it "should not save without a fund_source" do
      fund_tier_assignment.fund_source = nil
      fund_tier_assignment.save.should be_false
    end

    it "should not save without an organization" do
      fund_tier_assignment.organization = nil
      fund_tier_assignment.save.should be_false
    end

    it "should not save with a duplicate organization for a fund_source" do
      fund_tier_assignment.save!
      duplicate = build(:fund_tier_assignment,
        fund_source: fund_tier_assignment.fund_source,
        organization: fund_tier_assignment.organization )
      duplicate.save.should be_false
    end

    it "should not save without a fund_tier" do
      fund_tier_assignment.fund_tier = nil
      fund_tier_assignment.save.should be_false
    end

    it "should not save with an ineligible fund_tier" do
      bad_tier = create(:fund_tier)
      fund_tier_assignment.fund_source.fund_tiers.should_not include bad_tier
      fund_tier_assignment.fund_tier = bad_tier
      fund_tier_assignment.save.should be_false
    end
  end

  context 'adopt_fund_grant' do
    let(:fund_grant) { create(:fund_grant) }

    it "should adopt an existing fund_grant" do
      fund_grant.fund_tier_assignment.should be_nil
      fund_grant.fund_source.fund_tiers << create(:fund_tier)
      fund_tier_assignment = create( :fund_tier_assignment,
        fund_source: fund_grant.fund_source,
        organization: fund_grant.organization )
      fund_tier_assignment.fund_grant.should eql fund_grant
    end
  end
end

