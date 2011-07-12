require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'approver_scenarios'

describe Approver do

  include SpecApproverScenarios

  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:approver).id.should_not be_nil
  end

  it "should not save without framework" do
    approver = Factory(:approver)
    approver.framework = nil
    approver.save.should be_false
  end

  it "should not save without role" do
    approver = Factory(:approver)
    approver.role = nil
    approver.save.should be_false
  end

  it "should not save with invalid perspective" do
    approver = Factory(:approver)
    approver.perspective = 'invalid'
    FundEdition::PERSPECTIVES.should_not include(approver.perspective)
    approver.save.should be_false
  end

  it "should not save duplicate approvers" do
    original = Factory(:approver)
    second = original.clone
    second.save.should be_false
  end

  it 'should have an unfulfilled_for scope that returns unfulfilled approver conditions' do
    [ [0,'all'], [1,'half'], [2,'no'], [1,'no_reviewed'], [0, 'all_reviewed'] ].each do |s|
      quantity, scenario = *s
      send("#{scenario}_approvers_scenario",true)
      [ @fund_request.state, @fund_request.review_state ].should include 'tentative'
      scope = Approver.unfulfilled_for( @fund_request )
      scope.length.should eql quantity
      scope.should include @quota if quantity == 2 && @fund_request.state == 'tentative'
      scope.should include @all if quantity > 0 && @fund_request.state == 'tentative'
      scope.should include @review if quantity > 0 && @fund_request.review_state == 'tentative'
    end
  end

  it 'should have an fulfilled_for scope that returns fulfilled approver conditions' do
    [ [0,'no'], [1,'half'], [2,'all'], [0,'no_reviewed'], [1,'all_reviewed'] ].each do |s|
      quantity, scenario = *s
      send("#{scenario}_approvers_scenario",true)
      scope = Approver.fulfilled_for( @fund_request )
      scope.length.should eql quantity
      scope.should include @all if quantity == 2 && @fund_request.state == 'tentative'
      scope.should include @quota if quantity > 0 && @fund_request.state == 'tentative'
      scope.should include @review if quantity > 0 && @fund_request.review_state == 'tentative'
    end
  end

end

