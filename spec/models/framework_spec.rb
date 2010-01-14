require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Framework do
  before(:each) do
    @framework = Factory(:framework)
  end

  it "should create a new instance given valid attributes" do
    @framework.id.should_not be_nil
  end

  it "should not save without a name" do
    @framework.name = ""
    @framework.save.should == false
  end

  it "should not save with a name that is not unique" do
    second_framework = Factory.build(:framework,:name => @framework.name)
    second_framework.save.should == false
  end

  it "should include the GlobalModelAuthorization module" do
    Framework.included_modules.should include(GlobalModelAuthorization)
  end

end

