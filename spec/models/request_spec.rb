require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec/lib/approver_scenarios'

describe Request do

  include SpecApproverScenarios

  before(:each) do
    @request = Factory.build(:request)
  end

  it "should create a new instance given valid attributes" do
    @request.save.should eql true
  end

  it "should not save without an organization" do
    @request.organization = nil
    @request.save.should eql false
  end

  it "should not save with an invalid approval_checkpoint" do
    @request.save
    @request.approval_checkpoint = nil
    @request.save.should eql false
  end

  it "should reset approval checkpoint on transition to submitted" do
    @request.save
    initial = @request.approval_checkpoint
    @request.reload
    first_approval = @request.approvals.create( :user => Factory(:user), :as_of => @request.updated_at )
    @request.reload
    @request.status.should == 'completed'
    sleep 1
    last = @request.approvals.create( :user => Factory(:user), :as_of => @request.updated_at )
    @request.reload
    initial.should_not == last.created_at
    @request.status.should == 'submitted'
    @request.approval_checkpoint.should > initial
  end

  it "should have a retriever method for each perspective" do
    request = Factory(:request)
    Edition::PERSPECTIVES.each do |perspective|
      request.send(perspective).class.should eql Organization
    end
  end

  it "should call deliver_required_approval_notice on entering completed state" do
    @request.save
    @request.should_receive(:deliver_required_approval_notice)
    @request.approve.should == true
    @request.status.should == 'completed'
  end

  it "should call deliver_release_notice and set released_at on entering the released state" do
    @request.status = 'certified'
    @request.save
    m = Factory(:membership, :organization => @request.organization, :role => Factory(:requestor_role))
    @request.should_receive(:deliver_release_notice)
    @request.released_at.should be_nil
    @request.release.should == true
    @request.released_at.should_not be_nil
    @request.status.should == 'released'
  end

  it "should set accepted_at on entering accepted state" do
    @request.status = 'submitted'
    @request.save
    @request.accepted_at.should be_nil
    @request.accept.should == true
    @request.accepted_at.should_not be_nil
  end

  it "should have items.allocate which enforces caps" do
    first_edition = Factory(:edition)
    first_edition.amount = 100.0
    first_edition.save
    first_item = first_edition.item
    first_item.node.item_quantity_limit = 3
    first_item.node.save
    second_item = first_item.clone
    second_item.position = nil
    second_item.save
    second_item.editions.create!( Factory.attributes_for(:edition, :amount => 100.0 ) )
    first_item.reload
    first_item.editions.next.save!
    second_item.reload
    second_item.editions.next.save!
    request = first_item.request
    request.items.allocate(150.0)
    request.items.first.amount.should eql 100
    request.items.last.amount.should eql 50
    request.items.allocate(nil)
    request.items.first.amount.should eql 100
    request.items.last.amount.should eql 100
    request.items.allocate(0.0)
    request.items.first.amount.should eql 0
    request.items.last.amount.should eql 0
  end

  it 'should have an incomplete_for_perspective scope that returns requests that are incomplete for a perspective' do
    complete = Factory(:edition).item.request
    complete.editions.should_not be_empty
    incomplete = Factory(:item).request
    incomplete.editions.should be_empty
    Request.incomplete_for_perspective('requestor').should_not include complete
    Request.incomplete_for_perspective('reviewer').should include complete
    Request.incomplete_for_perspective('requestor').should include incomplete
    Request.incomplete_for_perspective('reviewer').should include incomplete
  end

  it 'should have an approvable? method that will not allow approval if there are missing editions' do
    complete = Factory(:edition).item.request
    incomplete = Factory(:item).request
    reviewed = Factory(:edition).item.request
    reviewed.status = 'accepted'
    Factory(:edition, :perspective => 'reviewer', :item => reviewed.items.first)
    unreviewed = Factory(:edition).item.request
    unreviewed.status = 'accepted'
    complete.approvable?.should be_true
    incomplete.approvable?.should be_false
    reviewed.approvable?.should be_true
    unreviewed.approvable?.should be_false
  end

  it 'should have users.unfulfilled method that returns users eligible towards current unfulfilled approver conditions' do
    { 0 => 'all', 4 => 'no', 1 => 'half' }.each do |quantity, scenario|
      send("#{scenario}_approvers_scenario",true)
      scope = @request.users.unfulfilled
      scope.length.should eql quantity
      scope.should include @quota_fulfilled if quantity == 4
      scope.should include @quota_unfulfilled if quantity > 1
      scope.should include @all_fulfilled if quantity == 4
      scope.should include @all_unfulfilled if quantity > 0
    end
  end

end

