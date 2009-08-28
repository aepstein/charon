require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SpeakerExpense do
  before(:each) do
    @expense = Factory(:speaker_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save without a version" do
    @expense.version = nil
    @expense.save.should == false
  end

  it "should not save without a speaker name" do
    @expense.speaker_name = ''
    @expense.save.should == false
  end

  it "should not save without a performance date" do
    @expense.performance_date = nil
    @expense.save.should == false
    @expense.performance_date = 'blah'
    @expense.save.should == false
  end

  it "should not save with invalid mileage" do
    @expense.mileage = nil
    @expense.save.should == false
    @expense.mileage = -13
    @expense.save.should == false
  end

  it "should not save with invalid number of speakers" do
    @expense.number_of_speakers = nil
    @expense.save.should == false
    @expense.number_of_speakers = -1
    @expense.save.should == false
  end

  it "should not save with invalid nights of lodging" do
    @expense.nights_of_lodging = nil
    @expense.save.should == false
    @expense.nights_of_lodging = -1
    @expense.save.should == false
  end

  it "should not save with invalid engagement fee" do
    @expense.engagement_fee = nil
    @expense.save.should == false
    @expense.engagement_fee = -1.01
    @expense.save.should == false
  end

  it "should not save with invalid car rental" do
    @expense.car_rental = nil
    @expense.save.should == false
    @expense.car_rental = -10.01
    @expense.save.should == false
  end

end

