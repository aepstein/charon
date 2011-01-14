require 'spec_helper'

describe AccountTransaction do
  before(:each) do
    @transaction = Factory(:account_transaction)
  end

  it 'should not save without a status' do
    @transaction.status = nil
    @transaction.save.should be_false
  end

  it 'should not save without an effective_on date' do
    @transaction.effective_on = nil
    @transaction.save.should be_false
  end

end

