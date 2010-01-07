require 'spec_helper'

describe UserStatusCriterion do
  before(:each) do
    @criterion = Factory(:user_status_criterion)
  end

  it "should create a new instance given valid attributes" do
    @criterion.id.should_not be_nil
  end
end

