require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Version do
  before(:each) do
    @version = Factory(:version)
  end

  it "should save with valid attributes" do
    Factory(:version).id.should_not be_nil
  end

  it "should not save without an item" do
    version = Factory(:version)
    version.item = nil
    version.save.should == false
  end

  it "should not save with an invalid perspective" do
    version = Factory(:version)
    version.perspective = 'invalid'
    Version::PERSPECTIVES.should_not include(version.perspective)
    version.save.should == false
  end

  it "should not save with a duplicate perspective for item" do
    version = Factory(:version)
    duplicate_version = Factory.build(:version, :item => version.item)
    duplicate_version.save.should == false
  end

  it "should not save with an amount higher than requestable.max_request" do
    detail = Factory(:administrative_expense)
    detail.id.should_not be_nil
    version = detail.version
    version.requestable(true).should_not be_nil
    version.requestable.stub!(:max_request).and_return(50.0)
    version.amount = 500.0
    version.save.should == false
  end

  it "should not save with an amount higher than original version amount" do
    detail = Factory(:administrative_expense)
    original = detail.version
    review = original.item.versions.next( :administrative_expense_attributes => Factory.attributes_for(:administrative_expense),
      :amount => (original.amount + 1.0) )
    review.perspective.should == 'reviewer'
    review.amount.should > original.amount
    review.save.should == false
    review.errors.first.to_s.should == 'amount is greater than original request amount.'
  end

  it "should have may_create? which is true if request.may_revise? and in review stage" do
    @version.request.stub!(:may_revise?).and_return(true)
    @version.perspective = 'reviewer'
    @version.may_create?(nil).should == true
    @version.perspective = 'requestor'
    @version.may_create?(nil).should == false
    @version.request.stub!(:may_revise?).and_return(false)
    @version.may_create?(nil).should == false
  end

  it "should have may_update? which is true if request.may_update? and in request stage or
      if request.may_revise? and in review stage" do
    @version.perspective = 'requestor'
    @version.request.stub!(:may_update?).and_return(true)
    @version.may_update?(nil).should == true
    @version.request.stub!(:may_update?).and_return(false)
    @version.may_update?(nil).should == false
    @version.perspective = 'reviewer'
    @version.request.stub!(:may_revise?).and_return(true)
    @version.may_update?(nil).should == true
    @version.request.stub!(:may_revise?).and_return(false)
    @version.may_update?(nil).should == false
  end

  it "should have may_destroy? which is false" do
    @version.perspective = 'requestor'
    @version.may_destroy?(nil).should == false
    @version.perspective = 'reviewer'
    @version.may_destroy?(nil).should == false
  end

  it "should have may_see? which is true if request.may_see? and in request stage or
      if (request.may_revise? or request.may_review?) and in review stage" do
    @version.perspective = 'requestor'
    @version.request.stub!(:may_see?).and_return(true)
    @version.may_see?(nil).should == true
    @version.request.stub!(:may_see?).and_return(false)
    @version.may_see?(nil).should == false
    @version.perspective = 'reviewer'
    @version.request.stub!(:may_revise?).and_return(false)
    @version.request.stub!(:may_review?).and_return(false)
    @version.may_see?(nil).should == false
    @version.request.stub!(:may_revise?).and_return(true)
    @version.may_see?(nil).should == true
    @version.request.stub!(:may_review?).and_return(true)
    @version.may_see?(nil).should == true
    @version.request.stub!(:may_revise?).and_return(false)
    @version.may_see?(nil).should == true
  end

  it "should item.touch on save" do
    @version.item.request.should_receive(:touch)
    @version.item.should_receive(:touch)
    @version.save
  end

  it "should have a title method that returns the requestable title if defined, nil otherwise" do
    title = 'a title'
    version = Factory(:administrative_expense).version
    version.requestable(true).should_not be_nil
    version.title.should be_nil
    version.administrative_expense.stub!(:title).and_return(nil)
    version.title.should be_nil
    version.administrative_expense.stub!(:title).and_return(title)
    version.title.should == title
  end

  it "should set its item's title to its own title if it has one on save" do
    title = 'a title'
    version = Factory(:version)
    version.stub!(:title).and_return(title)
    version.title.should_not == version.item.title
    version.save
    version.item.title.should == title
  end
end

