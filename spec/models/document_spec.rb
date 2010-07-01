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

end

