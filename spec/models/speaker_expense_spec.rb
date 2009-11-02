require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SpeakerExpense do
  before(:each) do
    @expense = Factory(:speaker_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save without a edition" do
    @expense.edition = nil
    @expense.save.should == false
  end

  it "should not save without a title" do
    @expense.title = ''
    @expense.save.should == false
  end

  it "should not save with invalid distance" do
    @expense.distance = nil
    @expense.save.should == false
    @expense.distance = -13
    @expense.save.should == false
  end

  it "should not save with invalid number of speakers" do
    @expense.number_of_travelers = nil
    @expense.save.should == false
    @expense.number_of_travelers = -1
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

end

