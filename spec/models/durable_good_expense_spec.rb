require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DurableGoodExpense do
  before(:each) do
    @expense = create(:durable_good_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save without a price" do
    @expense.price = nil
    @expense.save.should == false
  end

  it "should not save without a quantity" do
    @expense.quantity = nil
    @expense.save.should == false
  end

  it "should not save without a description" do
    @expense.description = ""
    @expense.save.should == false
  end

end

