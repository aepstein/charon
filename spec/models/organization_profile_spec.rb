require 'spec_helper'

describe OrganizationProfile do
  before(:each) do
    @profile = create(:organization_profile)
  end

  it "should create a new instance given valid attributes" do
    @profile.id.should_not be_nil
  end

  it 'should not save without valid anticipated_expenses' do
    @profile.anticipated_expenses = nil
    @profile.save.should be_false
    @profile.anticipated_expenses = -1.0
    @profile.save.should be_false
  end

  it 'should not save without valid anticipated_income' do
    @profile.anticipated_income = nil
    @profile.save.should be_false
    @profile.anticipated_income = -1.0
    @profile.save.should be_false
  end

  it 'should not save without valid current_assets' do
    @profile.current_assets = nil
    @profile.save.should be_false
    @profile.current_assets = -1.0
    @profile.save.should be_false
  end

  it 'should not save without valid current_liabilities' do
    @profile.current_liabilities = nil
    @profile.save.should be_false
    @profile.current_liabilities = -1.0
    @profile.save.should be_false
  end

  it 'should correctly calculate net_equity' do
    @profile.anticipated_expenses = 0.01
    @profile.anticipated_income = 0.1
    @profile.current_liabilities = 1.0
    @profile.current_assets = 10.0
    @profile.net_equity.should eql 9.09
  end

  it 'should not save without an organization' do
    @profile.organization = nil
    @profile.save.should be_false
  end
end

