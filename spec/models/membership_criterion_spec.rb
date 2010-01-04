require 'spec_helper'

describe MembershipCriterion do
  before(:each) do
    @valid_attributes = {
      :minimal_percentage => 1,
      :type_of_member => "value for type_of_member"
    }
  end

  it "should create a new instance given valid attributes" do
    MembershipCriterion.create!(@valid_attributes)
  end
end
