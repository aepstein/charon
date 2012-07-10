require 'spec_helper'

describe FundGrant do

  let(:fund_grant) { build :fund_grant }

  context 'validations' do
    it 'should save with valid attributes' do
      fund_grant.save!
    end

    it 'should not save without an organization' do
      fund_grant.organization = nil
      fund_grant.save.should be_false
    end

    it 'should not save without a fund_source' do
      fund_grant.fund_source = nil
      fund_grant.save.should be_false
    end

    it 'should not save a duplicate fund_source for given organization' do
      fund_grant.save!
      duplicate = build(:fund_grant,
        :organization => fund_grant.organization,
        :fund_source => fund_grant.fund_source )
      duplicate.save.should be_false
    end
  end

  context 'accessors' do
    it "should have a retriever method for each perspective" do
      FundEdition::PERSPECTIVES.each do |perspective|
        fund_grant.send(perspective).class.should eql Organization
      end
    end
  end

  context 'activity_accounts relation' do

    let(:fund_grant) { create :fund_grant }
    let(:included_category) { create(:fund_item, fund_grant: fund_grant).node.category }
    let(:excluded_category) { create(:category) }

    context 'categories.without_activity_account' do

      before(:each) { included_category; excluded_category }

      it "should return allocated categories with no activity account" do
        fund_grant.categories.without_activity_account.should include included_category
        fund_grant.categories.without_activity_account.should_not include excluded_category
      end

      it "should exclude included category if activity_account already created" do
        create :activity_account, fund_grant: fund_grant, category: included_category
        fund_grant.categories.without_activity_account.should_not include  included_category
      end

    end

    context "activity_accounts.populate!" do

      it "should create an activity account for an unpopulated, included category" do
        included_category
        fund_grant.activity_accounts.populate!
        fund_grant.activity_account_categories.should include included_category
      end

      it "should not create an activity account for an unpopulated, excluded category" do
        excluded_category
        fund_grant.activity_accounts.populate!
      end

      it "should not create an activity account for a populated, included category" do
        account = create :activity_account, fund_grant: fund_grant, category: included_category
        fund_grant.association(:activity_accounts).reset
        fund_grant.association(:activity_account_categories).reset
        fund_grant.activity_accounts.should include account
        fund_grant.activity_accounts.length.should eql 1
        fund_grant.activity_accounts.populate!
        fund_grant.activity_accounts.length.should eql 1
      end

    end

  end

  context 'scopes' do

    let(:fund_grant) { create :fund_grant }
    let(:closed) { create :closed_fund_grant }
    let(:upcoming) { create :upcoming_fund_grant }

    it 'should have a closed scope' do
      FundGrant.closed.should include closed
      FundGrant.closed.should_not include fund_grant, upcoming
    end

    it 'should have a current scope' do
      FundGrant.current.should include fund_grant
      FundGrant.current.should_not include upcoming, closed
    end
  end

end

