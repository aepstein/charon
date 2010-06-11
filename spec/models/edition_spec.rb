require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Edition do
  before(:each) do
    @edition = Factory(:edition)
  end

  it "should save with valid attributes" do
    Factory(:edition).id.should_not be_nil
  end

  it "should not save without an item" do
    edition = Factory(:edition)
    edition.item = nil
    edition.save.should == false
  end

  it "should not save with an invalid perspective" do
    edition = Factory(:edition)
    edition.perspective = 'invalid'
    Edition::PERSPECTIVES.should_not include(edition.perspective)
    edition.save.should == false
  end

  it "should not save with a duplicate perspective for item" do
    edition = Factory(:edition)
    duplicate_edition = Factory.build(:edition, :item => edition.item)
    duplicate_edition.save.should == false
  end

  it "should not save without an invalid amount" do
    edition = Factory(:edition)
    edition.amount = nil
    edition.save.should == false
    edition.amount = -1.02
    edition.save.should == false
  end

  it "should not save with an amount higher than item.node.item_amount_limit" do
    @edition.amount = @edition.item.node.item_amount_limit + 1
    @edition.save.should == false
    @edition.errors.first.to_s.should == "amount is greater than maximum for #{@edition.item.node}."
    @edition.max_request.should eql @edition.item.node.item_amount_limit
  end

  it "should not save with an amount higher than requestable.max_request" do
    detail = Factory(:administrative_expense)
    detail.id.should_not be_nil
    edition = detail.edition
    edition.requestable(true).should_not be_nil
    edition.requestable.stub!(:max_request).and_return(50.0)
    edition.amount = 500.0
    edition.save.should == false
    edition.max_request.should eql edition.requestable.max_request
  end

  it "should not save with an amount higher than original edition amount" do
    original = Factory(:edition)
    original.item.reload
    review = original.item.editions.next( :amount => (original.amount + 1.0) )
    review.perspective.should eql 'reviewer'
    review.amount.should > original.amount
    review.save.should eql false
    review.errors.first.to_s.should eql "amount is greater than original request amount."
    review.max_request.should eql original.amount
  end

  it "should have a title method that returns the requestable title if defined, nil otherwise" do
    title = 'a title'
    edition = Factory(:administrative_expense).edition
    edition.requestable(true).should_not be_nil
    edition.title.should be_nil
    edition.administrative_expense.stub!(:title).and_return(nil)
    edition.title.should be_nil
    edition.administrative_expense.stub!(:title).and_return(title)
    edition.title.should == title
  end

  it "should set its item's title to its own title if it has one on save" do
    title = 'a title'
    edition = Factory(:edition)
    edition.stub!(:title).and_return(title)
    edition.title.should_not == edition.item.title
    edition.save
    Item.find(edition.item.id).title.should == title
  end
end

