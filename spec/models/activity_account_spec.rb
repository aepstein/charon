require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActivityAccount do
  before(:each) do
    @account = Factory(:activity_account)
  end

  it 'should save with valid properties' do
    @account.id.should_not be_nil
  end

  it 'should not save without a university account' do
    @account.university_account = nil
    @account.save.should be_false
  end

  it 'should not save with a duplicate university account for given basis and category' do
    @account.basis = Factory(:basis)
    @account.category = Factory(:category)
    @account.save!
    duplicate = Factory.build( :activity_account, :basis => @account.basis,
      :university_account => @account.university_account,
      :category => @account.category )
    duplicate.save.should be_false
  end
end

