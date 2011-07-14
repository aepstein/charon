require 'spec_helper'

describe AccountTransaction do
  before(:each) do
    @transaction = create(:account_transaction)
  end

  it 'should not save without a status' do
    @transaction.status = nil
    @transaction.save.should be_false
  end

  it 'should not save without an effective_on date' do
    @transaction.effective_on = nil
    @transaction.save.should be_false
  end

  it 'should have a balance method that accurately figures balances' do
    setup_adjustments -100.0, 101.1
    @transaction.adjustments.balance.should eql 1.1
  end

  it 'should not save with adjustments out of balance' do
    setup_adjustments -5.5, 5.6
    @transaction.adjustments.balanced?.should be_false
    @transaction.save.should be_false
  end

  def setup_adjustments( from = -100.0, to = 100.0 )
    @from = create( :activity_account)
    @to = create( :activity_account )
    @transaction.adjustments.build( :activity_account => @from, :amount => from )
    @transaction.adjustments.build( :activity_account => @to, :amount => to )
  end

end

