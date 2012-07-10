require 'spec_helper'

describe FundTier do

  let(:fund_tier) { build :fund_tier }

  it "should save with valid attributes" do
    fund_tier.save!
  end

  context "validations" do
    it "should not save without an organization" do
      fund_tier.organization = nil
      fund_tier.save.should be_false
    end

    it "should not save without a valid maximum_allocation" do
      fund_tier.maximum_allocation = nil
      fund_tier.save.should be_false
      fund_tier.maximum_allocation = 'blah'
      fund_tier.save.should be_false
    end

    it "should not save duplicate maximum_allocation for same organization" do
      fund_tier.save!
      duplicate = build( :fund_tier, organization: fund_tier.organization,
        maximum_allocation: fund_tier.maximum_allocation )
      duplicate.save.should be_false
    end
  end
end

