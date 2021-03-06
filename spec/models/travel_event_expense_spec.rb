require 'spec_helper'

describe TravelEventExpense do
  before(:each) do
    @expense = create(:travel_event_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save without a fund_edition" do
    @expense.fund_edition = nil
    @expense.save.should be_false
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

  it "should not save with invalid members per group" do
    @expense.travelers_per_group = nil
    @expense.save.should be_false
    @expense.travelers_per_group = 0
    @expense.save.should be_false
  end

  it "should not save with invalid number of groups" do
    @expense.number_of_groups = nil
    @expense.save.should be_false
    @expense.number_of_groups = 0
    @expense.save.should be_false
  end

  it "should not save with invalid mileage" do
    @expense.distance = nil
    @expense.save.should == false
    @expense.distance = -1
    @expense.save.should == false
  end

  it "should not save with invalid nights of lodging" do
    @expense.nights_of_lodging = nil
    @expense.save.should == false
    @expense.nights_of_lodging = -1
    @expense.save.should == false
  end

  it "should not save with invalid per person fees" do
    @expense.per_person_fees = nil
    @expense.save.should == false
    @expense.per_person_fees = -1.01
    @expense.save.should == false
  end

  it "should not save with invalid per group fees" do
    @expense.per_group_fees = nil
    @expense.save.should == false
    @expense.per_group_fees = -1.01
    @expense.save.should == false
  end

end

