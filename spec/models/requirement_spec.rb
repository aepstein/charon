require 'spec_helper'

describe Requirement do
  before(:each) do
    @requirement = Factory(:requirement)
  end

  it "should create a new instance given valid attributes" do
    @requirement.id.should_not be_nil
  end
end

