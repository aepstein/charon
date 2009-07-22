require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:permission).id.should_not be_nil
  end
end

