require 'spec_helper'

describe UserStatusCriterion do
  before(:each) do
    @valid_attributes = {
      :statuses_mask => 1
    }
  end

  it "should create a new instance given valid attributes" do
    UserStatusCriterion.create!(@valid_attributes)
  end
end
