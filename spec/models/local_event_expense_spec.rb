require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LocalEventExpense do
  before(:each) do
    @expense = Factory(:local_event_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save with an invalid or blank date" do
    @expense.date_of_event = nil
    @expense.save.should == false
    @expense.date_of_event = 'blah'
    @expense.save.should == false
  end

  it "should not save without a title" do
    @expense.title_of_event = ''
    @expense.save.should == false
  end

  it "should not save without a location" do
    @expense.location_of_event = ''
    @expense.save.should == false
  end

  it "should not save without a purpose" do
    @expense.purpose_of_event = ''
    @expense.save.should == false
  end

  it "should not save without anticipated attendees" do
    @expense.anticipated_no_of_attendees = nil
    @expense.save.should == false
  end

  it "should not save without admission charge" do
    @expense.admission_charge_per_attendee = nil
    @expense.save.should == false
  end

  it "should not save without copies" do
    @expense.number_of_publicity_copies = nil
    @expense.save.should == false
  end

  it "should not save without services" do
    @expense.rental_equipment_services = nil
    @expense.save.should == false
  end

end

