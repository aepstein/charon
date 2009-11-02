require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Document do
  before(:each) do
  end

  after(:each) do
    Document.all.each { |document| document.destroy }
  end

  it "should create a new instance given valid attributes" do
    Factory(:document).id.should_not be_nil
  end

  it "should not save without an edition" do
    document = Factory(:document)
    document.edition = nil
    document.save.should == false
  end

  it "should not save without an document type" do
    document = Factory(:document)
    document.document_type = nil
    document.save.should == false
  end

  it "should not create if it conflicts with an existing document type for an edition" do
    document = Factory(:document)
    duplicate = document.clone
    duplicate.save.should == false
  end

  it "should have may_create? and may_update? that return edition.may_update?" do
    document = Factory.build(:document)
    document.edition.stub!(:may_update?).and_return(true)
    document.may_create?(nil).should == true
    document.may_update?(nil).should == true
    document.edition.stub!(:may_update?).and_return(false)
    document.may_create?(nil).should == false
    document.may_update?(nil).should == false
  end

  it "should have may_destroy? that returns edition.may_destroy?" do
    document = Factory(:document)
    document.edition.stub!(:may_destroy?).and_return(true)
    document.may_destroy?(nil) == true
    document.edition.stub!(:may_destroy?).and_return(false)
    document.may_destroy?(nil) == true
  end

  it "should have may_see? that returns edition.may_see?" do
    document = Factory(:document)
    document.edition.stub!(:may_see?).and_return(true)
    document.may_see?(nil) == true
    document.edition.stub!(:may_see?).and_return(false)
    document.may_see?(nil) == true
  end
end

