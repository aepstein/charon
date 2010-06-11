require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Basis do
  before(:each) do
    @basis = Factory(:basis)
  end

  it "should create a new instance given valid attributes" do
    Factory(:basis).id.should_not be_nil
  end

  it 'should not save without a contact name' do
    @basis.contact_name = nil
    @basis.save.should be_false
  end

  it 'should not save without a contact email' do
    @basis.contact_email = nil
    @basis.save.should be_false
  end

  it 'should not save without a contact web' do
    @basis.contact_web = nil
    @basis.save.should be_false
  end

  it 'should not save with a submissions_due_at after the close date' do
    @basis.submissions_due_at = @basis.closed_at + 1.day
    @basis.save.should be_false
  end

  it "should not save with a close date before the open date" do
    basis = Factory.build(:basis)
    basis.open_at = DateTime.now + 1.days
    basis.closed_at = DateTime.now - 1.days
    basis.save.should be_false
  end

  it "should have a requests.item_amount_for_status method" do
    item = Factory(:item, :amount => 54.3)
    item.request.basis.requests.item_amount_for_status(item.request.status).should == item.amount
  end

  it "should not save without a structure" do
    basis = Factory(:basis)
    basis.structure = nil
    basis.save.should be_false
  end

end

