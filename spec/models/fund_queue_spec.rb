require 'spec_helper'

describe FundQueue do

  before :each do
    @fund_queue = build(:fund_queue)
  end

  it 'should save with valid attributes' do
    @fund_queue.save!
  end

  it 'should not save without a fund_source' do
    @fund_queue.fund_source = nil
    @fund_queue.save.should be_false
  end

  it 'should not save without submit_at' do
    @fund_queue.submit_at = nil
    @fund_queue.save.should be_false
  end

  it 'should not save with submit_at >= release_at' do
    @fund_queue.submit_at = @fund_queue.release_at
    @fund_queue.save.should be_false
    @fund_queue.submit_at += 1.day
    @fund_queue.save.should be_false
  end

  it 'should not save with submit_at <= fund_source.open_at' do
    @fund_queue.submit_at = @fund_queue.fund_source.open_at
    @fund_queue.save.should be_false
    @fund_queue.submit_at -= 1.day
    @fund_queue.save.should be_false
  end

  it 'should not save without release_at' do
    @fund_queue.release_at = nil
    @fund_queue.save.should be_false
  end

  it 'should not save with advertised_submit_at > submit_at' do
    @fund_queue.advertised_submit_at = @fund_queue.submit_at + 1.minute
    @fund_queue.save.should be_false
  end

end

