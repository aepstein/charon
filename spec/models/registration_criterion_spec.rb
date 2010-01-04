require 'spec_helper'

describe RegistrationCriterion do
  before(:each) do
    @valid_attributes = {
      :must_register => false
    }
  end

  it "should create a new instance given valid attributes" do
    RegistrationCriterion.create!(@valid_attributes)
  end
end
