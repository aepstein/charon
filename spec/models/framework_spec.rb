require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec/lib/requirement_scenarios'

describe Framework do

  include SpecRequirementScenarios

  before(:each) do
    @framework = Factory(:framework)
  end

  it "should create a new instance given valid attributes" do
    @framework.id.should_not be_nil
  end

  it "should not save without a name" do
    @framework.name = ""
    @framework.save.should == false
  end

  it "should not save with a name that is not unique" do
    second_framework = Factory.build(:framework,:name => @framework.name)
    second_framework.save.should == false
  end

  it 'should have a fulfilled_for scope that returns only frameworks fulfilled for fulfiller, perspective' do
    Framework.delete_all
    setup_requirements_scenario
    no_requirements_framework = Factory(:framework)
    @fulfillers.keys.each do |fulfiller|
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should include @framework
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should_not include @framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should_not include no_requirements_framework
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should include @framework
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should_not include @framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should_not include no_requirements_framework
    end
    @unfulfillers.values.each do |fulfiller|
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should_not include @framework
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should include @framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.first ).should_not include no_requirements_framework
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should include @framework
      Framework.fulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should_not include @framework
      Framework.unfulfilled_for( fulfiller, Edition::PERSPECTIVES.last ).should_not include no_requirements_framework
    end
  end

end

