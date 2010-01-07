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

  it 'should not save without a fulfillable' do
    @fulfillment.fulfillable = nil
    @fulfillment.save.should eql false
  end

  it 'should not save without a fulfiller' do
    @fulfillment.fulfiller = nil
    @fulfillment.save.should eql false
  end

  it 'should not save with a fulfiller that is not allowed for the fulfillable' do
    @fulfillment.fulfillable = Factory(:agreement)
    @fulfillment.fulfiller = Factory(:organization)
    @fulfillment.save.should eql false
    @fulfillment.fulfillable = Factory(:user_status_criterion)
    @fulfillment.save.should eql false
    @fulfillment.fulfillable = Factory(:registration_criterion)
    @fulfillment.fulfiller = Factory(:user)
    @fulfillment.save.should eql false
  end

  it 'should not save with a disallowed fulfillable' do
    @fulfillment.fulfillable = Factory(:registration)
    @fulfillment.save.should eql false
  end
end

