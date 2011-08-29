require 'spec_helper'

describe LocalEventExpense do
  before(:each) do
    @expense = create(:local_event_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save with an invalid or blank start date" do
    @expense.start_date = nil
    @expense.save.should be_false
    @expense.start_date = 'blah'
    @expense.save.should be_false
  end

  it "should not save with an invalid or blank end date" do
    @expense.end_date = nil
    @expense.save.should be_false
    @expense.end_date = 'blah'
    @expense.save.should be_false
  end

  it "should not save without a title" do
    @expense.title = ''
    @expense.save.should be_false
  end

  it "should not save without a location" do
    @expense.location = ''
    @expense.save.should be_false
  end

  it "should not save without a purpose" do
    @expense.purpose = ''
    @expense.save.should be_false
  end

  it "should not save without anticipated attendees" do
    @expense.number_of_attendees = ''
    @expense.save.should be_false
  end

  it "should not save without admission charge" do
    @expense.price_per_attendee = ''
    @expense.save.should be_false
  end

  it "should not save without copies" do
    @expense.copies_quantity = ''
    @expense.save.should be_false
  end

end

