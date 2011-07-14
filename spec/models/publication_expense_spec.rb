require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PublicationExpense do
  before(:each) do
    @expense = create(:publication_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save without a title" do
    @expense.title = ''
    @expense.save.should == false
  end

  it "should not save with invalid number of issues" do
    @expense.number_of_issues = nil
    @expense.save.should == false
    @expense.number_of_issues = -1
    @expense.save.should == false
  end

  it "should not save with invalid number of copies per issue" do
    @expense.copies_per_issue = nil
    @expense.save.should == false
    @expense.copies_per_issue = -1
    @expense.save.should == false
  end

  it "should not save with invalid purchase price" do
    @expense.price_per_copy = nil
    @expense.save.should == false
    @expense.price_per_copy = -1.01
    @expense.save.should == false
  end

  it "should not save without cost publication" do
    @expense.cost_per_issue = nil
    @expense.save.should == false
    @expense.cost_per_issue = -1.00
    @expense.save.should == false
  end

  it "should not save without a fund_edition" do
    @expense.fund_edition = nil
    @expense.save.should == false
  end
end

