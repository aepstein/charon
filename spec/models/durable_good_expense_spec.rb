require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DurableGoodExpense do
  before(:each) do
    @valid_attributes = {
      :description => "value for description",
      :quantity => 1.5,
      :price => 1.5,
      :total => 9.99
    }
  end

  it "should create a new instance given valid attributes" do
    DurableGoodExpense.create!(@valid_attributes)
  end
end
