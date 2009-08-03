require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AttachmentType do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:attachment_type).id.should_not be_nil
  end

  it "should not save with an invalid max_size_quantity" do
    attachment_type = Factory(:attachment_type)
    attachment_type.max_size_quantity = nil
    attachment_type.save.should == false
    attachment_type.max_size_quantity = 0
    attachment_type.save.should == false
    attachment_type.max_size_quantity = 'roger'
    attachment_type.save.should == false
    attachment_type.max_size_quantity = 10.2
    attachment_type.save.should == false
  end

  it "should not save with an invalid max_size_unit" do
    attachment_type = Factory(:attachment_type)
    attachment_type.max_size_unit = 'invalid'
    AttachmentType::UNITS.should_not include( attachment_type.max_size_unit )
    attachment_type.save.should == false
  end

  it "should not save with a duplicate name" do
    attachment_type = Factory(:attachment_type)
    duplicate = attachment_type.clone
    duplicate.name.should == attachment_type.name
    duplicate.save.should == false
    duplicate.name = "#{duplicate.name} unique"
    duplicate.save.should == true
  end

  it "should include GlobalModelAuthorization module" do
    AttachmentType.included_modules.should include( GlobalModelAuthorization )
  end
end

