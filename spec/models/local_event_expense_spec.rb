require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LocalEventExpense do
  before(:each) do
    @expense = create(:local_event_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save with an invalid or blank date" do
    @expense.date = nil
    @expense.save.should == false
    @expense.date = 'blah'
    @expense.save.should == false
  end

  it "should not save without a title" do
    @expense.title = ''
    @expense.save.should == false
  end

  it "should not save without a location" do
    @expense.location = ''
    @expense.save.should == false
  end

  it "should not save without a purpose" do
    @expense.purpose = ''
    @expense.save.should == false
  end

  it "should not save without anticipated attendees" do
    @expense.number_of_attendees = ''
    @expense.save.should == false
  end

  it "should not save without admission charge" do
    @expense.price_per_attendee = ''
    @expense.save.should == false
  end

  it "should not save without copies" do
    @expense.copies_quantity = ''
    @expense.save.should == false
  end

  it "should not save without services" do
    @expense.services_cost = ''
    @expense.save.should == false
  end

end

