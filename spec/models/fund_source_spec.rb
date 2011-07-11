require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundSource do
  before(:each) do
    @fund_source = Factory(:fund_source)
  end

  it "should create a new instance given valid attributes" do
    Factory(:fund_source).id.should_not be_nil
  end

  it 'should not save without a contact name' do
    @fund_source.contact_name = nil
    @fund_source.save.should be_false
  end

  it 'should not save without a contact email' do
    @fund_source.contact_email = nil
    @fund_source.save.should be_false
  end

  it 'should not save without a contact web' do
    @fund_source.contact_web = nil
    @fund_source.save.should be_false
  end

  it 'should not save with a submissions_due_at after the close date' do
    @fund_source.submissions_due_at = @fund_source.closed_at + 1.day
    @fund_source.save.should be_false
  end

  it "should not save with a close date before the open date" do
    fund_source = Factory.build(:fund_source)
    fund_source.open_at = DateTime.now + 1.days
    fund_source.closed_at = DateTime.now - 1.days
    fund_source.save.should be_false
  end

  # TODO new data model requires this spec to be reworked
  xit "should have a fund_requests.fund_item_amount_for_status method" do
    fund_item = Factory(:fund_item, :amount => 54.3)
    fund_item.fund_request.fund_grant.fund_source.fund_requests.fund_item_amount_for_status(fund_item.fund_request.status).should == fund_item.amount
  end

  it "should not save without a structure" do
    fund_source = Factory(:fund_source)
    fund_source.structure = nil
    fund_source.save.should be_false
  end

end

