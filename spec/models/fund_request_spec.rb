require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'approver_scenarios'

describe FundRequest do

  include SpecApproverScenarios

  before(:each) do
    @fund_request = Factory.build(:fund_request)
  end

  context 'validation' do

    it "should create a new instance given valid attributes" do
      @fund_request.save!
    end

    it "should not save without an organization" do
      @fund_request.organization = nil
      @fund_request.save.should be_false
    end

    it "should not save with an invalid approval_checkpoint" do
      @fund_request.save
      @fund_request.approval_checkpoint = nil
      @fund_request.save.should be_false
    end

  end

  it "should reset approval checkpoint on transition to submitted" do
    @fund_request.save
    initial = @fund_request.approval_checkpoint
    @fund_request.reload
    first_approval = @fund_request.approvals.build( :as_of => @fund_request.updated_at )
    first_approval.user = Factory(:user)
    first_approval.save!
    @fund_request.reload
    @fund_request.state.should eql 'completed'
    sleep 1
    last = @fund_request.approvals.build( :as_of => @fund_request.updated_at )
    last.user = Factory(:user)
    last.save!
    @fund_request.reload
    initial.should_not eql last.created_at
    @fund_request.state.should eql 'submitted'
    @fund_request.approval_checkpoint.should > initial
  end

  it "should have a retriever method for each perspective" do
    fund_request = Factory(:fund_request)
    FundEdition::PERSPECTIVES.each do |perspective|
      fund_request.send(perspective).class.should eql Organization
    end
  end

  it "should call deliver_required_approval_notice on entering completed state" do
    @fund_request.save!
    @fund_request.should_receive(:deliver_required_approval_notice)
    @fund_request.approvable?.should be_true
    @fund_request.approve!
    @fund_request.state.should eql 'completed'
  end

  it "should call deliver_release_notice and set released_at on entering the released state" do
    m = Factory(:membership, :organization => @fund_request.fund_grant.organization, :role => Factory(:fund_requestor_role))
    @fund_request.state = 'certified'
    @fund_request.save!
    @fund_request.reload
    @fund_request.state.should eql 'certified'
    @fund_request.should_receive(:send_released_notice!)
#    @fund_request.should_receive(:timestamp_state!)
    @fund_request.released_at.should be_nil
    @fund_request.release!
    @fund_request.released_at.should_not be_nil
    @fund_request.reload
    @fund_request.state.should eql 'released'
  end

  it "should set accepted_at on entering accepted state" do
    @fund_request.state = 'submitted'
    @fund_request.save!
    @fund_request.accepted_at.should be_nil
    @fund_request.accept!
    @fund_request.accepted_at.should_not be_nil
  end

  it "should have fund_items.allocate which enforces caps" do
    first_fund_edition = Factory(:fund_edition)
    first_fund_edition.amount = 100.0
    first_fund_edition.save
    first_fund_item = first_fund_edition.fund_item
    first_fund_item.node.item_quantity_limit = 3
    first_fund_item.node.save
    second_fund_item = first_fund_item.clone
    second_fund_item.position = nil
    second_fund_item.save
    e = second_fund_item.fund_editions.build
    Factory.attributes_for(:fund_edition, :amount => 100.0 ).each do |k, v|
      e.send("#{k}=", v)
    end
    e.save!
    first_fund_item.reload
    first_fund_item.fund_editions.next.save!
    second_fund_item.reload
    second_fund_item.fund_editions.next.save!
    fund_request = first_fund_item.fund_request
    fund_request.fund_items.allocate(150.0)
    fund_request.fund_items.first.amount.should eql 100
    fund_request.fund_items.last.amount.should eql 50
    fund_request.fund_items.allocate(nil)
    fund_request.fund_items.first.amount.should eql 100
    fund_request.fund_items.last.amount.should eql 100
    fund_request.fund_items.allocate(0.0)
    fund_request.fund_items.first.amount.should eql 0
    fund_request.fund_items.last.amount.should eql 0
  end

  it 'should have an incomplete scope that returns fund_requests that have initial editions without final editions' do
    #TODO logic has changed for flexible_budgets
    complete = Factory(:fund_edition).fund_request
    complete.fund_editions.should_not be_empty
    incomplete = Factory(:fund_request, :fund_grant => Factory(:fund_item).fund_grant )
    incomplete.fund_editions.should be_empty
    FundRequest.incomplete.should_not include complete
    FundRequest.incomplete.should include complete
    FundRequest.incomplete.should include incomplete
    FundRequest.incomplete.should include incomplete
  end

  it 'should have an approvable? method that will not allow approval if there are missing fund_editions' do
    complete = Factory(:fund_edition).fund_request
    incomplete = Factory(:fund_request, :fund_grant => Factory(:fund_item).fund_grant)
    reviewed = Factory(:fund_edition).fund_request
    reviewed.state = 'accepted'
    Factory(:fund_edition, :perspective => 'reviewer', :fund_item => reviewed.fund_items.first)
    unreviewed = Factory(:fund_edition).fund_request
    unreviewed.state = 'accepted'
    complete.approvable?.should be_true
    incomplete.approvable?.should be_false
    reviewed.approvable?.should be_true
    unreviewed.approvable?.should be_false
  end

  it 'should have users.unfulfilled method that returns users eligible towards current unfulfilled approver conditions' do
    { 0 => 'all', 4 => 'no', 1 => 'half' }.each do |quantity, scenario|
      send("#{scenario}_approvers_scenario",true)
      scope = @fund_request.users.unfulfilled
      scope.length.should eql quantity
      scope.should include @quota_fulfilled if quantity == 4
      scope.should include @quota_unfulfilled if quantity > 1
      scope.should include @all_fulfilled if quantity == 4
      scope.should include @all_unfulfilled if quantity > 0
    end
  end

  it 'should have a perspective_for method that identifies a user\'s perspective' do
    fund_requestor_role = Factory(:fund_requestor_role)
    reviewer_role = Factory(:reviewer_role)
    fund_requestor_organization = Factory(:organization)
    reviewer_organization = Factory(:organization)
    fund_requestor = Factory(:membership, :role => fund_requestor_role, :active => true, :organization => fund_requestor_organization).user
    conflictor = Factory(:membership, :role => fund_requestor_role, :active => true, :organization => fund_requestor_organization).user
    Factory(:membership, :role => reviewer_role, :active => true, :organization => reviewer_organization, :user => conflictor)
    reviewer = Factory(:membership, :role => reviewer_role, :active => true, :organization => reviewer_organization).user
    fund_source = Factory(:fund_source, :organization => reviewer_organization)
    fund_request = Factory(:fund_request, :fund_source => fund_source, :organization => fund_requestor_organization)
    [
      [ fund_requestor, 'fund_requestor' ], [ conflictor, 'fund_requestor' ], [ reviewer, 'reviewer' ],
      [ fund_requestor_organization, 'fund_requestor' ], [ reviewer_organization, 'reviewer' ]
    ].each do |scenario|
      fund_request.perspective_for( scenario.first ).should eql scenario.last
    end
  end

  it 'should have a duplicate scope' do
    @fund_request.save
    duplicate = Factory(:fund_request, :fund_source => @fund_request.fund_source, :organization => @fund_request.organization)
    same_organization = Factory(:fund_request, :organization => @fund_request.organization)
    same_fund_source = Factory(:fund_request, :fund_source => @fund_request.fund_source)
    different = Factory(:fund_request)
    duplicates = FundRequest.duplicate
    duplicates.count.should eql 2
    duplicates.should include @fund_request
    duplicates.should include duplicate
  end

  it 'should have a notify_unnotified! class method' do
    other_state = Factory(:fund_request, :state => 'completed')
    unnotified = Factory(:fund_request)
    notified_before = Factory(:fund_request)
    notified_before.update_attribute :started_notice_at, 1.week.ago
    notified_before.reload
    week_ago = notified_before.started_notice_at
    FundRequest.notify_unnotified! :started
    unnotified.reload
    unnotified_notice_at = unnotified.started_notice_at
    unnotified_notice_at.should be_within(5.seconds).of(Time.zone.now)
    notified_before.reload
    notified_before.started_notice_at.should eql week_ago
    sleep 1
    FundRequest.notify_unnotified! :started, 1.day.ago
    unnotified.reload
    unnotified.started_notice_at.should eql unnotified_notice_at
    notified_before.reload
    notified_before.started_notice_at.should be_within(5.seconds).of(Time.zone.now)
  end

end

