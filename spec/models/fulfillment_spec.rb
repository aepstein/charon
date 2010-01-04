require 'spec_helper'

describe Fulfillment do
  before(:each) do
    @valid_attributes = {
      :fulfiller_id => 1,
      :fulfiller_type => "value for fulfiller_type",
      :fulfilled_id => 1,
      :fulfilled_type => "value for fulfilled_type"
    }
  end

  it "should create a new instance given valid attributes" do
    Fulfillment.create!(@valid_attributes)
  end
end
