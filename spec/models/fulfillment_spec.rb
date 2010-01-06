require 'spec_helper'

describe Fulfillment do
  before(:each) do
    @fulfillment = Factory(:fulfillment)
  end

  it "should create a new instance given valid attributes" do
    @fulfillment.id.should_not be_nil
  end

  it 'should have a self.fulfiller_type_for_fulfillable that returns correct results' do
    Fulfillment.fulfiller_type_for_fulfillable(Agreement.new).should eql 'User'
    Fulfillment.fulfiller_type_for_fulfillable('Agreement').should eql 'User'
    Fulfillment.fulfiller_type_for_fulfillable('RegistrationCriterion').should eql 'Organization'
    Fulfillment.fulfiller_type_for_fulfillable('UserStatusCriterion').should eql 'User'
    Fulfillment.fulfiller_type_for_fulfillable('Basis').should be_nil
  end
end

