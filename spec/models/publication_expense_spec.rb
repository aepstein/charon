require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PublicationExpense do
  before(:each) do
    @expense = Factory(:publication_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save with invalid number of issues" do
    @expense.no_of_issues = nil
    @expense.save.should == false
    @expense.no_of_issues = -1
    @expense.save.should == false
  end

  it "should not save with invalid number of copies per issue" do
    @expense.no_of_copies_per_issue = nil
    @expense.save.should == false
    @expense.no_of_copies_per_issue = -1
    @expense.save.should == false
  end

  it "should not save with invalid purchase price" do
    @expense.purchase_price = nil
    @expense.save.should == false
    @expense.purchase_price = -1.01
    @expense.save.should == false
  end

  it "should not save without cost publication" do
    @expense.cost_publication = nil
    @expense.save.should == false
    @expense.cost_publication = -1.00
    @expense.save.should == false
  end

  it "should not save without a version" do
    @expense.version = nil
    @expense.save.should == false
  end
end

