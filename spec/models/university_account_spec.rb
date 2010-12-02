require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UniversityAccount do
  before(:each) do
    @university_account = Factory(:university_account)
  end

  it "should create a new instance given valid attributes" do
    @university_account.id.should_not be_nil
  end

  it 'should not save a duplicate department_code/subledger_code combination' do
    duplicate = Factory.build(:university_account)
    duplicate.department_code = @university_account.department_code
    duplicate.subledger_code = @university_account.subledger_code
    duplicate.save.should be_false
  end

  it 'should not save with an invalid department code' do
    %w( blah g889 89 889 ).each do |scenario|
      @university_account.department_code = scenario
      @university_account.save.should be_false
    end
    @university_account.department_code = nil
    @university_account.save.should be_false
  end

  it 'should not save with an invalid department code' do
    %w( blah g889 89 889 ).each do |scenario|
      @university_account.subledger_code = scenario
      @university_account.save.should be_false
    end
    @university_account.subledger_code = nil
    @university_account.save.should be_false
  end

  it 'should not save without an organization' do
    @university_account.organization = nil
    @university_account.save.should be_false
  end

end

