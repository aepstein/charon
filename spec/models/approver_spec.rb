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
    setup_approvers_scenario
    scope = Approver.unfulfilled_for( @request )
    scope.length.should eql 1
    scope.should include @all
    Factory(:approval, :approvable => @request, :user => @all_unfulfilled)
    scope.reload
    scope.length.should eql 0
    Approval.delete_all
    scope.reload
    scope.length.should eql 2
    scope.should include @quota
  end

  it 'should have an fulfilled_for scope that returns fulfilled approver conditions' do
    setup_approvers_scenario
    scope = Approver.fulfilled_for( @request )
    scope.length.should eql 1
    scope.should include @quota
    Factory(:approval, :approvable => @request, :user => @all_unfulfilled)
    scope.reload
    scope.length.should eql 2
    scope.should include @all
    Approval.delete_all
    scope.reload
    scope.length.should eql 0
  end

end

