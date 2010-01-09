require 'spec_helper'

describe Requirement do
  before(:each) do
    @requirement = Factory(:requirement)
  end

  it "should create a new instance given valid attributes" do
    @requirement.id.should_not be_nil
  end

  it 'should not save without a permission' do
    @requirement.permission = nil
    @requirement.save.should be_false
  end

  it 'should not save without a fulfillable' do
    @requirement.fulfillable = nil
    @requirement.save.should be_false
  end

  it 'should not save a duplicate' do
    duplicate = Factory.build(:requirement)
    duplicate.permission = @requirement.permission
    duplicate.fulfillable = @requirement.fulfillable
    duplicate.save.should be_false
  end

  it 'should not save a fulfillable that is not of a valid type' do
    @requirement.fulfillable = Factory(:user)
    Fulfillment::FULFILLABLE_TYPES.values.flatten.should_not include @requirement.fulfillable_type
    @requirement.save.should be_false
  end
end

