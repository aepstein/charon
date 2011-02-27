require 'spec_helper'

describe AccountAdjustment do
  before(:each) do
    @adjustment = Factory(:account_adjustment)
  end

  it 'should create an account with valid attributes' do
    @adjustment.id.should_not be_nil
  end

  it 'should not save without an amount' do
    @adjustment.amount = nil
    @adjustment.save.should be_false
  end

  it 'should not save without an account_transaction' do
    @adjustment.account_transaction = nil
    @adjustment.save.should be_false
  end

  it 'should not save without an activity_account' do
    @adjustment.activity_account = nil
    @adjustment.save.should be_false
  end
end

