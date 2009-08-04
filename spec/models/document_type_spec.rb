require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DocumentType do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:document_type).id.should_not be_nil
  end

  it "should not save with an invalid max_size_quantity" do
    document_type = Factory(:document_type)
    document_type.max_size_quantity = nil
    document_type.save.should == false
    document_type.max_size_quantity = 0
    document_type.save.should == false
    document_type.max_size_quantity = 'roger'
    document_type.save.should == false
    document_type.max_size_quantity = 10.2
    document_type.save.should == false
  end

  it "should not save with an invalid max_size_unit" do
    document_type = Factory(:document_type)
    document_type.max_size_unit = 'invalid'
    DocumentType::UNITS.should_not include( document_type.max_size_unit )
    document_type.save.should == false
  end

  it "should not save with a duplicate name" do
    document_type = Factory(:document_type)
    duplicate = document_type.clone
    duplicate.name.should == document_type.name
    duplicate.save.should == false
    duplicate.name = "#{duplicate.name} unique"
    duplicate.save.should == true
  end

  it "should include GlobalModelAuthorization module" do
    DocumentType.included_modules.should include( GlobalModelAuthorization )
  end
end

