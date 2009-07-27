require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
  end

  it "should save a valid user" do
    Factory(:user).id.should_not be_nil
  end

end

