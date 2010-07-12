require 'spec_helper'

describe InventoryItem do
  before(:each) do
    @inventory_item = Factory(:inventory_item)
  end

  it "should create a new instance given valid attributes" do
    @inventory_item.id.should_not be_nil
  end

  it 'should not save without a description' do
    @inventory_item.description = nil
    @inventory_item.save.should be_false
  end

  it 'should not save with a duplicate identifier' do
    @inventory_item.identifier = 'Boat1'
    @inventory_item.save
    duplicate = Factory.build(:inventory_item, :organization => @inventory_item.organization)
    duplicate.identifier = @inventory_item.identifier
    duplicate.save.should be_false
  end

  it 'should not save with invalid purchase_price' do
    @inventory_item.purchase_price = -1.0
    @inventory_item.save.should be_false
    @inventory_item.purchase_price = nil
    @inventory_item.save.should be_false
  end

  it 'should not save invalid current_value' do
    @inventory_item.current_value = -1.0
    @inventory_item.save.should be_false
    @inventory_item.current_value = nil
    @inventory_item.save.should be_false
  end

  it 'should not save without a valid acquired_on date' do
    @inventory_item.acquired_on = nil
    @inventory_item.save.should be_false
    @inventory_item.acquired_on = "date"
    @inventory_item.save.should be_false
  end

  it 'should not save without a valid scheduled_retirement_on date' do
    @inventory_item.scheduled_retirement_on = nil
    @inventory_item.save.should be_false
    @inventory_item.scheduled_retirement_on = "date"
    @inventory_item.save.should be_false
    @inventory_item.scheduled_retirement_on = @inventory_item.acquired_on
    @inventory_item.save.should be_false
  end

  it 'should not save with an invalid retired_on date' do
    @inventory_item.retired_on = @inventory_item.acquired_on - 1.day
    @inventory_item.save.should be_false
    @inventory_item.retired_on = nil
    @inventory_item.save.should be_true
    @inventory_item.retired_on = @inventory_item.acquired_on + 1.day
    @inventory_item.save.should be_true
  end
end

