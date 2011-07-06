require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InventoryFundItem do
  before(:each) do
    @inventory_fund_item = Factory(:inventory_fund_item)
  end

  it "should create a new instance given valid attributes" do
    @inventory_fund_item.id.should_not be_nil
  end

  it 'should not save without a description' do
    @inventory_fund_item.description = nil
    @inventory_fund_item.save.should be_false
  end

  it 'should not save with a duplicate identifier' do
    @inventory_fund_item.identifier = 'Boat1'
    @inventory_fund_item.save
    duplicate = Factory.build(:inventory_fund_item, :organization => @inventory_fund_item.organization)
    duplicate.identifier = @inventory_fund_item.identifier
    duplicate.save.should be_false
  end

  it 'should not save with invalid purchase_price' do
    @inventory_fund_item.purchase_price = -1.0
    @inventory_fund_item.save.should be_false
    @inventory_fund_item.purchase_price = nil
    @inventory_fund_item.save.should be_false
  end

  it 'should not save invalid current_value' do
    @inventory_fund_item.current_value = -1.0
    @inventory_fund_item.save.should be_false
    @inventory_fund_item.current_value = nil
    @inventory_fund_item.save.should be_false
  end

  it 'should not save without a valid acquired_on date' do
    @inventory_fund_item.acquired_on = nil
    @inventory_fund_item.save.should be_false
    @inventory_fund_item.acquired_on = "date"
    @inventory_fund_item.save.should be_false
  end

  it 'should not save without a valid scheduled_retirement_on date' do
    @inventory_fund_item.scheduled_retirement_on = nil
    @inventory_fund_item.save.should be_false
    @inventory_fund_item.scheduled_retirement_on = "date"
    @inventory_fund_item.save.should be_false
    @inventory_fund_item.scheduled_retirement_on = @inventory_fund_item.acquired_on
    @inventory_fund_item.save.should be_false
  end

  it 'should not save with an invalid retired_on date' do
    @inventory_fund_item.retired_on = @inventory_fund_item.acquired_on - 1.day
    @inventory_fund_item.save.should be_false
    @inventory_fund_item.retired_on = nil
    @inventory_fund_item.save.should be_true
    @inventory_fund_item.retired_on = @inventory_fund_item.acquired_on + 1.day
    @inventory_fund_item.save.should be_true
  end
end

