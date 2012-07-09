require 'spec_helper'

describe ActivityAccount do

  let(:activity_account) { build :activity_account }

  context 'validation' do

    it 'should save with valid properties' do
      activity_account.save!
    end

    it 'should not save without a fund_grant' do
      activity_account.fund_grant = nil
      activity_account.save.should be_false
    end

    it "should not save without a category" do
      activity_account.category = nil
      activity_account.save.should be_false
    end

    it 'should not save with a duplicate university account for given fund_source and category' do
      activity_account.fund_grant = create(:fund_grant)
      activity_account.category = create(:category)
      activity_account.save!
      duplicate = build( :activity_account, fund_grant: activity_account.fund_grant,
        category: activity_account.category )
      duplicate.save.should be_false
    end

  end

  context "temporal scopes" do

    let(:activity_account) { create :activity_account }
    let(:closed_activity_account) { create :closed_activity_account }

    it "should have a current scope that returns only current" do
      ActivityAccount.current.should include activity_account
      ActivityAccount.current.should_not include closed_activity_account
    end

    it "should have a closed scope that returns only closed" do
      ActivityAccount.closed.should_not include activity_account
      ActivityAccount.closed.should include closed_activity_account
    end

  end

end

