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

end

