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

    it "should not save without a fund_grant" do
      @fund_request.fund_grant = nil
      @fund_request.save.should be_false
    end

    it "should not save with an invalid approval_checkpoint" do
      @fund_request.save
      @fund_request.approval_checkpoint = nil
      @fund_request.save.should be_false
    end

  end

  it "should reset approval checkpoint on transition to submitted" do
    queue = Factory(:fund_queue, :fund_source => @fund_request.fund_grant.fund_source)
    @fund_request.fund_grant.fund_source.fund_queues.reset
    @fund_request.state = 'tentative'
    @fund_request.save!
    @fund_request.update_attribute :approval_checkpoint, 2.seconds.ago
    old = @fund_request.approval_checkpoint
    @fund_request.fund_queue = queue
    @fund_request.submit!
    @fund_request.approval_checkpoint.should > old
  end

  it "should have a retriever method for each perspective" do
    fund_request = Factory(:fund_request)
    FundEdition::PERSPECTIVES.each do |perspective|
      fund_request.send(perspective).class.should eql Organization
    end
  end

  it "should call deliver_required_approval_notice on entering tentative state" do
    @fund_request.save!
    @fund_request.should_receive(:deliver_required_approval_notice)
    @fund_request.approvable?.should be_true
    @fund_request.approve!
    @fund_request.state.should eql 'tentative'
  end

  it "should call deliver_release_notice and set released_at on entering the released state" do
    m = Factory(:membership, :organization => @fund_request.fund_grant.organization, :role => Factory(:requestor_role))
    queue = Factory( :fund_queue, :fund_source => @fund_request.fund_grant.fund_source )
    @fund_request.fund_grant.fund_source.fund_queues.reset
    @fund_request.state = 'submitted'
    @fund_request.fund_queue = queue
    @fund_request.review_state = 'ready'
    @fund_request.save!
    @fund_request.should_receive(:send_released_notice!)
    @fund_request.released_at.should be_nil
    @fund_request.release!
    @fund_request.released_at.should_not be_nil
    @fund_request.state.should eql 'released'
  end

  it "should set submitted_at on entering submitted state" do
    Factory(:fund_queue, :fund_source => @fund_request.fund_grant.fund_source)
    @fund_request.fund_grant.fund_source.fund_queues.reset
    @fund_request.state = 'tentative'
    @fund_request.save!
    @fund_request.should_receive( :send_submitted_notice! )
    @fund_request.submitted_at.should be_nil
    @fund_request.submit!
    @fund_request.submitted_at.should_not be_nil
  end

  it "should have fund_items.allocate! which enforces caps" do
    @fund_request.save!
    first_fund_item = Factory(:fund_item, :fund_grant => @fund_request.fund_grant)
    second_fund_item = Factory(:fund_item, :fund_grant => @fund_request.fund_grant)
    2.times do |i|
      first_fund_item.fund_editions.build_next_for_fund_request( @fund_request,
        { :amount => 100.0 } ).save!
      second_fund_item.fund_editions.build_next_for_fund_request( @fund_request,
        { :amount => 100.0 } ).save!
    end
    @fund_request.reload
    @fund_request.fund_items.length.should eql 2
    @fund_request.fund_editions.length.should eql 4
    @fund_request.fund_items.allocate!(150.0)
    @fund_request.fund_items.first.amount.should eql 100
    @fund_request.fund_items.last.amount.should eql 50
    @fund_request.fund_items.allocate!
    @fund_request.fund_items.first.amount.should eql 100
    @fund_request.fund_items.last.amount.should eql 100
    @fund_request.fund_items.allocate!(0.0)
    @fund_request.fund_items.first.amount.should eql 0
    @fund_request.fund_items.last.amount.should eql 0
  end

  it 'should have an incomplete scope that returns fund_requests that have initial editions without final editions' do
    initial = Factory(:fund_edition)
    Factory(:fund_edition, :fund_request => initial.fund_request,
      :fund_item => initial.fund_item, :perspective => FundEdition::PERSPECTIVES.last )
    complete = initial.fund_request
    incomplete = Factory(:fund_edition).fund_request
    FundRequest.incomplete.should_not include complete
    FundRequest.incomplete.should include incomplete
  end

  it 'should have an approvable? method that will not allow approval of started request unless all new items have an edition' do
    @fund_request.save!
    item = Factory(:fund_edition, :fund_request => @fund_request).fund_item
    @fund_request.approvable?.should be_true
    second_item = Factory(:fund_item, :fund_grant => @fund_request.fund_grant)
    @fund_request.reload
    @fund_request.approvable?.should be_false
  end

  it 'should have an approvable? method that will not allow approval of submitted requests unless all initial editions have corresponding finals' do
    queue = Factory(:fund_queue, :fund_source => @fund_request.fund_grant.fund_source)
    @fund_request.fund_grant.fund_source.reload
    @fund_request.fund_queue = queue
    @fund_request.state = 'submitted'
    @fund_request.save!
    item = Factory(:fund_edition, :fund_request => @fund_request).fund_item
    @fund_request.reload
    @fund_request.approvable?.should be_false
    item.reload
    item.fund_editions.build_next_for_fund_request( @fund_request ).save!
    @fund_request.reload
    @fund_request.approvable?.should be_true
  end

  it 'should have users.unfulfilled method that returns users eligible towards current unfulfilled unquantified approver conditions' do
    { 0 => 'all', 2 => 'no', 1 => 'half' }.each do |quantity, scenario|
      send("#{scenario}_approvers_scenario",true)
      scope = @fund_request.users.unfulfilled
      scope.length.should eql quantity
      scope.should_not include @quota_fulfilled
      scope.should_not include @quota_unfulfilled
      scope.should include @all_fulfilled if quantity == 2
      scope.should include @all_unfulfilled if quantity > 0
    end
  end

  it 'should have a perspective_for method that identifies a user\'s perspective' do
    requestor_role = Factory(:requestor_role)
    reviewer_role = Factory(:reviewer_role)
    requestor_organization = Factory(:organization)
    reviewer_organization = Factory(:organization)
    requestor = Factory(:membership, :role => requestor_role, :active => true, :organization => requestor_organization).user
    conflictor = Factory(:membership, :role => requestor_role, :active => true, :organization => requestor_organization).user
    Factory(:membership, :role => reviewer_role, :active => true, :organization => reviewer_organization, :user => conflictor)
    reviewer = Factory(:membership, :role => reviewer_role, :active => true, :organization => reviewer_organization).user
    fund_source = Factory(:fund_source, :organization => reviewer_organization)
    fund_grant = Factory(:fund_grant, :fund_source => fund_source,
      :organization => requestor_organization)
    fund_request = Factory(:fund_request, :fund_grant => fund_grant)
    [
      [ requestor, 'requestor' ], [ conflictor, 'requestor' ], [ reviewer, 'reviewer' ],
      [ requestor_organization, 'requestor' ], [ reviewer_organization, 'reviewer' ]
    ].each do |scenario|
      fund_request.perspective_for( scenario.first ).should eql scenario.last
    end
  end

  it 'should have a duplicate scope' do
    @fund_request.save!
    duplicate = Factory(:fund_request, :fund_grant => @fund_request.fund_grant)
    different = Factory(:fund_request)
    duplicates = FundRequest.duplicate
    duplicates.count.should eql 2
    duplicates.should include @fund_request
    duplicates.should include duplicate
  end

  it 'should have a notify_unnotified! class method' do
    other_state = Factory(:fund_request, :state => 'tentative')
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

