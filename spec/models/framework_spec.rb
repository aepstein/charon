require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'requirement_scenarios'

describe Framework do

  include SpecRequirementScenarios

  before(:each) do
    @framework = create(:framework)
  end

  it "should create a new instance given valid attributes" do
    @framework.id.should_not be_nil
  end

  it "should not save without a name" do
    @framework.name = ""
    @framework.save.should == false
  end

  it "should not save with a name that is not unique" do
    second_framework = build(:framework,:name => @framework.name)
    second_framework.save.should == false
  end

  it 'should have a fulfilled_for scope that returns only frameworks fulfilled for fulfiller, perspective' do
    Framework.delete_all
    setup_requirements_scenario
    no_requirements_framework = create(:framework)
    @fulfillers.keys.each do |fulfiller|
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should include @framework
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should_not include @framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should_not include no_requirements_framework
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should include @framework
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should_not include @framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should_not include no_requirements_framework
    end
    @unfulfillers.values.each do |fulfiller|
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should_not include @framework
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should include @framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.first, nil ).should_not include no_requirements_framework
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should include @framework
      Framework.fulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should include no_requirements_framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should_not include @framework
      Framework.unfulfilled_for( fulfiller, FundEdition::PERSPECTIVES.last, nil ).should_not include no_requirements_framework
    end
  end

  it 'should have a fulfilled_for/unfulfilled_for scope that can be role-limited' do
    setup_requirements_role_limited_scenario
    Framework.fulfilled_for( @all, FundEdition::PERSPECTIVES.first, [] ).should include @framework
    Framework.unfulfilled_for( @all, FundEdition::PERSPECTIVES.first, [] ).should_not include @framework
    Framework.fulfilled_for( @all, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should include @framework
    Framework.unfulfilled_for( @all, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should_not include @framework
    Framework.fulfilled_for( @all, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should include @framework
    Framework.unfulfilled_for( @all, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should_not include @framework

    Framework.fulfilled_for( @limited, FundEdition::PERSPECTIVES.first, [] ).should_not include @framework
    Framework.unfulfilled_for( @limited, FundEdition::PERSPECTIVES.first, [] ).should include @framework
    Framework.fulfilled_for( @limited, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should_not include @framework
    Framework.unfulfilled_for( @limited, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should include @framework
    Framework.fulfilled_for( @limited, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should_not include @framework
    Framework.unfulfilled_for( @limited, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should include @framework

    Framework.fulfilled_for( @unlimited, FundEdition::PERSPECTIVES.first, [] ).should include @framework
    Framework.unfulfilled_for( @unlimited, FundEdition::PERSPECTIVES.first, [] ).should_not include @framework
    Framework.fulfilled_for( @unlimited, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should_not include @framework
    Framework.unfulfilled_for( @unlimited, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should include @framework
    Framework.fulfilled_for( @unlimited, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should include @framework
    Framework.unfulfilled_for( @unlimited, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should_not include @framework

    Framework.fulfilled_for( @no, FundEdition::PERSPECTIVES.first, [] ).should_not include @framework
    Framework.unfulfilled_for( @no, FundEdition::PERSPECTIVES.first, [] ).should include @framework
    Framework.fulfilled_for( @no, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should_not include @framework
    Framework.unfulfilled_for( @no, FundEdition::PERSPECTIVES.first, [@limited_role.id] ).should include @framework
    Framework.fulfilled_for( @no, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should_not include @framework
    Framework.unfulfilled_for( @no, FundEdition::PERSPECTIVES.first, [@unlimited_role.id] ).should include @framework
  end

end

