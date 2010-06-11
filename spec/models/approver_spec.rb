require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec/lib/approver_scenarios'

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
    approver.save.should == false
  end

  it "should not save without role" do
    approver = Factory(:approver)
    approver.role = nil
    approver.save.should == false
  end

  it "should not save with invalid status" do
    approver = Factory(:approver)
    approver.status = 'invalid'
    Request.aasm_state_names.should_not include(approver.status)
    approver.save.should == false
  end

  it "should not save with invalid perspective" do
    approver = Factory(:approver)
    approver.perspective = 'invalid'
    Edition::PERSPECTIVES.should_not include(approver.perspective)
    approver.save.should == false
  end

  it "should not save duplicate approvers" do
    original = Factory(:approver)
    second = original.clone
    second.save.should == false
  end

  it 'should have an unfulfilled_for scope that returns unfulfilled approver conditions' do
    [ [0,'all'], [1,'half'], [2,'no'], [1,'no_reviewed'], [0, 'all_reviewed'] ].each do |s|
      quantity, scenario = *s
      send("#{scenario}_approvers_scenario",true)
      %w( completed reviewed ).should include @request.status
      scope = Approver.unfulfilled_for( @request )
      scope.length.should eql quantity
      scope.should include @quota if quantity == 2 && @request.status == 'completed'
      scope.should include @all if quantity > 0 && @request.status == 'completed'
      scope.should include @review if quantity > 0 && @request.status == 'reviewed'
    end
  end

  it 'should have an fulfilled_for scope that returns fulfilled approver conditions' do
    [ [0,'no'], [1,'half'], [2,'all'], [0,'no_reviewed'], [1,'all_reviewed'] ].each do |s|
      quantity, scenario = *s
      send("#{scenario}_approvers_scenario",true)
      scope = Approver.fulfilled_for( @request )
      scope.length.should eql quantity
      scope.should include @all if quantity == 2 && @request.status == 'completed'
      scope.should include @quota if quantity > 0 && @request.status == 'completed'
      scope.should include @review if quantity > 0 && @request.status == 'reviewed'
    end
  end

end

