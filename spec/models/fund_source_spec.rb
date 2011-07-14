require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundSource do
  before(:each) do
    @fund_source = create(:fund_source)
  end

  context 'validations' do
    it "should create a new instance given valid attributes" do
      create(:fund_source).id.should_not be_nil
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

    it "should not save with a close date before the open date" do
      fund_source = build(:fund_source)
      fund_source.open_at = Time.zone.now + 1.days
      fund_source.closed_at = Time.zone.now - 1.days
      fund_source.save.should be_false
    end

    it "should not save without a structure" do
      fund_source = create(:fund_source)
      fund_source.structure = nil
      fund_source.save.should be_false
    end
  end

  context 'scopes' do
    it 'should have a closed scope' do
      generate_non_open_fund_sources
      FundSource.closed.length.should eql 1
      FundSource.closed.should include @closed
    end

    it 'should have an open scope' do
      generate_non_open_fund_sources
      FundSource.open.length.should eql 1
      FundSource.open.should include @fund_source
    end

    it 'should have an upcoming scope' do
      generate_non_open_fund_sources
      FundSource.upcoming.length.should eql 1
      FundSource.upcoming.should include @upcoming
    end
  end

  # TODO new data model requires this spec to be reworked
  xit "should have a fund_requests.fund_item_amount_for_status method" do
    fund_item = create(:fund_item, :amount => 54.3)
    fund_item.fund_request.fund_grant.fund_source.fund_requests.fund_item_amount_for_status(fund_item.fund_request.status).should == fund_item.amount
  end

  def generate_non_open_fund_sources
    @closed = create(:closed_fund_source)
    @upcoming = create(:upcoming_fund_source)
  end

end

