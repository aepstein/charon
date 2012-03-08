require 'spec_helper'

describe UniversityAccount do
  before(:each) do
    @university_account = create(:university_account)
  end

  it "should create a new instance given valid attributes" do
    @university_account.id.should_not be_nil
  end

  it 'should not save a duplicate account_code/subaccount_code combination' do
    duplicate = build(:university_account)
    duplicate.account_code = @university_account.account_code
    duplicate.save.should be_false
  end

  it 'should not save with a blank account code' do
    @university_account.account_code = nil
    @university_account.save.should be_false
  end

  it 'should not save with an invalid subaccount code' do
    %w( blah g889 89 889 8079 ).each do |scenario|
      @university_account.subaccount_code = scenario
      @university_account.save.should be_false
    end
    @university_account.subaccount_code = nil
    @university_account.save.should be_false
  end

  it 'should not save without an organization' do
    @university_account.organization = nil
    @university_account.save.should be_false
  end

end

