require 'spec_helper'
require 'spec/lib/requirement_scenarios'

describe Requirement do

  include SpecRequirementScenarios

  before(:each) do
    @requirement = Factory(:requirement)
  end

  it "should create a new instance given valid attributes" do
    @requirement.id.should_not be_nil
  end

  it 'should not save without a framework' do
    @requirement.framework = nil
    @requirement.save.should be_false
  end

  it 'should not save without a fulfillable' do
    @requirement.fulfillable = nil
    @requirement.save.should be_false
  end

  it 'should not save a duplicate' do
    duplicate = Factory.build(:requirement)
    duplicate.framework = @requirement.framework
    duplicate.fulfillable = @requirement.fulfillable
    duplicate.save.should be_false
  end

  it 'should not save a fulfillable that is not of a valid type' do
    @requirement.fulfillable = Factory(:user)
    Fulfillment::FULFILLABLE_TYPES.values.flatten.should_not include @requirement.fulfillable_type
    @requirement.save.should be_false
  end

  it 'should have a fulfilled_for scope that returns requirements that are fulfilled for fulfiller, perspective' do
    setup_requirements_scenario
    @fulfillers.each do |fulfiller, requirements|
      Requirement.fulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).length.should eql requirements.length
      Requirement.fulfilled_for( @unfulfillers[fulfiller], Edition::PERSPECTIVES.first ).length.should eql 0
      Requirement.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).length.should eql 0
      Requirement.unfulfilled_for( @unfulfillers[fulfiller], Edition::PERSPECTIVES.first ).length.should eql requirements.length
      Requirement.fulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).length.should eql 0
      Requirement.fulfilled_for( @unfulfillers[fulfiller], Edition::PERSPECTIVES.last ).length.should eql 0
      Requirement.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).length.should eql 0
      Requirement.unfulfilled_for( @unfulfillers[fulfiller], Edition::PERSPECTIVES.last ).length.should eql 0
    end
  end

end

