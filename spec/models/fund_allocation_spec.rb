require 'spec_helper'

describe FundAllocation do
  def fund_allocation
    @fund_allocation ||= build(:fund_allocation)
  end

  it 'should save with valid properties' do
    fund_allocation.save!
  end

  it 'should not save with a negative amount' do
    fund_allocation.amount = -1.0
    fund_allocation.save.should be_false
  end

  it 'should not save without a state' do
    fund_allocation.state = nil
    fund_allocation.save.should be_false
  end

  it 'should not save without a fund_item' do
    fund_allocation.fund_item = nil
    fund_allocation.save.should be_false
  end

  it 'should not save without a fund_request' do
    fund_allocation.fund_request = nil
    fund_allocation.save.should be_false
  end
end

