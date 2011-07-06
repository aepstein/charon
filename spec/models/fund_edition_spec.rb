require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundEdition do
  before(:each) do
    @fund_edition = Factory(:fund_edition)
  end

  it "should save with valid attributes" do
    Factory(:fund_edition).id.should_not be_nil
  end

  it "should not save without an fund_item" do
    fund_edition = Factory(:fund_edition)
    fund_edition.fund_item = nil
    fund_edition.save.should be_false
  end

  it "should not save with an invalid perspective" do
    fund_edition = Factory(:fund_edition)
    fund_edition.perspective = 'invalid'
    FundEdition::PERSPECTIVES.should_not include(fund_edition.perspective)
    fund_edition.save.should be_false
  end

  it "should not save with a duplicate perspective for fund_item" do
    fund_edition = Factory(:fund_edition)
    duplicate_fund_edition = Factory.build(:fund_edition, :fund_item => fund_edition.fund_item)
    duplicate_fund_edition.save.should be_false
  end

  it "should not save without an invalid amount" do
    fund_edition = Factory(:fund_edition)
    fund_edition.amount = nil
    fund_edition.save.should be_false
    fund_edition.amount = -1.02
    fund_edition.save.should be_false
  end

  it "should not save with an amount higher than fund_item.node.fund_item_amount_limit" do
    @fund_edition.amount = @fund_edition.fund_item.node.fund_item_amount_limit + 1
    @fund_edition.save.should be_false
    @fund_edition.errors.first.should eql [:amount, " is greater than maximum for #{@fund_edition.fund_item.node}."]
    @fund_edition.max_fund_request.should eql @fund_edition.fund_item.node.fund_item_amount_limit
  end

  it "should not save with an amount higher than fund_requestable.max_fund_request" do
    detail = Factory(:administrative_expense)
    detail.id.should_not be_nil
    fund_edition = detail.fund_edition
    fund_edition.fund_requestable(true).should_not be_nil
    fund_edition.fund_requestable.stub!(:max_fund_request).and_return(50.0)
    fund_edition.amount = 500.0
    fund_edition.save.should eql false
    fund_edition.max_fund_request.should eql fund_edition.fund_requestable.max_fund_request
  end

  it "should not save with an amount higher than original fund_edition amount" do
    original = Factory(:fund_edition)
    original.fund_item.reload
    review = original.fund_item.fund_editions.next
    review.amount = ( original.amount + 1.0 )
    review.perspective.should eql 'reviewer'
    review.amount.should > original.amount
    review.save.should be_false
    review.errors.first.should eql [:amount, " is greater than original fund_request amount."]
    review.max_fund_request.should eql original.amount
  end

  it "should have a title method that returns the fund_requestable title if defined, nil otherwise" do
    title = 'a title'
    fund_edition = Factory(:administrative_expense).fund_edition
    fund_edition.fund_requestable(true).should_not be_nil
    fund_edition.title.should be_nil
    fund_edition.administrative_expense.stub!(:title).and_return(nil)
    fund_edition.title.should be_nil
    fund_edition.administrative_expense.stub!(:title).and_return(title)
    fund_edition.title.should == title
  end

  it "should not save a non-initial fund_edition if a previous fund_edition does not exist" do
    fund_edition = Factory.build( :fund_edition, :perspective => FundEdition::PERSPECTIVES.last )
    fund_edition.save.should be_false
  end

  it "should set its fund_item's title to its own title if it has one on save" do
    title = 'a title'
    fund_edition = Factory(:fund_edition)
    fund_edition.stub!(:title).and_return(title)
    fund_edition.title.should_not eql fund_edition.fund_item.title
    fund_edition.save
    FundItem.find(fund_edition.fund_item.id).title.should eql title
  end
end

