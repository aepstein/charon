require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:category).id.should_not be_nil
  end

  it "should not save without a name" do
    category = Factory(:category)
    category.name = nil
    category.save.should == false
  end

  it "should not save without a unique name" do
    original = Factory(:category)
    duplicate = Factory.build(:category, :name => original.name)
    duplicate.save.should == false
  end

end

