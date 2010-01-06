require 'spec_helper'

describe RegistrationCriterion do
  before(:each) do
    @criterion = Factory(:registration_criterion)
  end

  it "should create a new instance given valid attributes" do
    @criterion.id.should_not be_nil
  end
end

