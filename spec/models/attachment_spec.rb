require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attachment do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:attachment).id.should_not be_nil
  end

  it "should not save without an attachable" do
    attachment = Factory(:attachment)
    attachment.attachable = nil
    attachment.save.should == false
  end

  it "should not save without an attachment type" do
    attachment = Factory(:attachment)
    attachment.attachment_type = nil
    attachment.save.should == false
  end

  it "should not create if it conflicts with an existing attachment type for an attachable" do
    attachment = Factory(:attachment)
    duplicate = attachment.clone
    duplicate.save.should == false
  end

  it "should have may_create? and may_update? that return attachable.may_update?" do
    attachment = Factory.build(:attachment)
    attachment.attachable.stub!(:may_update?).and_return(true)
    attachment.may_create?(nil).should == true
    attachment.may_update?(nil).should == true
    attachment.attachable.stub!(:may_update?).and_return(false)
    attachment.may_create?(nil).should == false
    attachment.may_update?(nil).should == false
  end

  it "should have may_destroy? that returns attachable.may_destroy?" do
    attachment = Factory(:attachment)
    attachment.attachable.stub!(:may_destroy?).and_return(true)
    attachment.may_destroy?(nil) == true
    attachment.attachable.stub!(:may_destroy?).and_return(false)
    attachment.may_destroy?(nil) == true
  end

  it "should have may_see? that returns attachable.may_see?" do
    attachment = Factory(:attachment)
    attachment.attachable.stub!(:may_see?).and_return(true)
    attachment.may_see?(nil) == true
    attachment.attachable.stub!(:may_see?).and_return(false)
    attachment.may_see?(nil) == true
  end
end

