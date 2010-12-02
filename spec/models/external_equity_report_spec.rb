require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExternalEquityReport do
  before(:each) do
    @report = Factory(:external_equity_report)
  end

  it "should create a new instance given valid attributes" do
    @report.id.should_not be_nil
  end

  it 'should not save without valid anticipated_expenses' do
    @report.anticipated_expenses = nil
    @report.save.should be_false
    @report.anticipated_expenses = -1.0
    @report.save.should be_false
  end

  it 'should not save without valid anticipated_income' do
    @report.anticipated_income = nil
    @report.save.should be_false
    @report.anticipated_income = -1.0
    @report.save.should be_false
  end

  it 'should not save without valid current_assets' do
    @report.current_assets = nil
    @report.save.should be_false
    @report.current_assets = -1.0
    @report.save.should be_false
  end

  it 'should not save without valid current_liabilities' do
    @report.current_liabilities = nil
    @report.save.should be_false
    @report.current_liabilities = -1.0
    @report.save.should be_false
  end

  it 'should correctly calculate net_equity' do
    @report.anticipated_expenses = 0.01
    @report.anticipated_income = 0.1
    @report.current_liabilities = 1.0
    @report.current_assets = 10.0
    @report.net_equity.should eql 9.09
  end

  it 'should not save without an edition' do
    @report.edition = nil
    @report.save.should be_false
  end
end

