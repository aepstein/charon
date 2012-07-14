require 'spec_helper'
require 'approver_scenarios'

describe FundRequest do

  include SpecApproverScenarios

  before(:each) do
    @fund_request = build(:fund_request)
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

    it 'should not save without a fund_request_type' do
      @fund_request.fund_request_type = nil
      @fund_request.save.should be_false
    end

    it 'should not save with fund_request_type that is not associated with the source through its queues' do
      @fund_request.fund_request_type = create( :fund_request_type )
      @fund_request.save.should be_false
    end

    it 'should not save first request with a requestable type that is not allowed for first' do
      @fund_request.fund_request_type.update_attribute :allowed_for_first, false
      @fund_request.save.should be_false
    end

    it 'should save a second request with a requestable type that is not allowed for first' do
      @fund_request.fund_queue = @fund_request.fund_grant.fund_source.fund_queues.first
      @fund_request.state = 'submitted'
      @fund_request.save!
      @fund_request.fund_request_type.update_column :allowed_for_first, false
      create( :fund_request, fund_grant: @fund_request.fund_grant,
        fund_request_type: @fund_request.fund_request_type )
    end

    it 'should not create if another draft request exists' do
      @fund_request.save!
      duplicate = build( :fund_request, :fund_grant => @fund_request.fund_grant,
        :fund_request_type => @fund_request.fund_request_type )
      %w( started tentative finalized ).each do |state|
        @fund_request.update_attribute :state, state
        duplicate.save.should be_false
      end
      @fund_request.update_attribute :state, 'submitted'
      duplicate.save!
    end
  end

  it 'should send a started_notice on create' do
    @fund_request.should_receive(:send_started_notice!)
    @fund_request.save!
  end

  it "should reset approval checkpoint on transition to submitted" do
    queue = @fund_request.fund_grant.fund_source.fund_queues.first
    @fund_request.state = 'tentative'
    @fund_request.save!
    @fund_request.update_attribute :approval_checkpoint, 2.seconds.ago
    old = @fund_request.approval_checkpoint
    @fund_request.fund_queue = queue
    @fund_request.submit!
    @fund_request.approval_checkpoint.should > old
  end

  it "should call deliver_required_approval_notice on entering tentative state" do
    @fund_request.save!
    create( :fund_edition, fund_request: @fund_request, amount: 100.0 )
    @fund_request.should_receive(:deliver_required_approval_notice)
    @fund_request.approvable?.should be_true
    @fund_request.approve!
    @fund_request.state.should eql 'tentative'
  end

  it "should call deliver_release_notice and set released_at on entering the released state" do
    m = create(:membership, :organization => @fund_request.fund_grant.organization, :role => create(:requestor_role))
    queue = @fund_request.fund_grant.fund_source.fund_queues.first
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
    @fund_request.state = 'tentative'
    @fund_request.save!
    @fund_request.should_receive( :send_submitted_notice! )
    @fund_request.submitted_at.should be_nil
    @fund_request.submit!
    @fund_request.submitted_at.should_not be_nil
  end

  it "should have fund_items.allocate! which enforces caps" do
    @fund_request.save!
    first_fund_item = create(:fund_item, :fund_grant => @fund_request.fund_grant)
    second_fund_item = create(:fund_item, :fund_grant => @fund_request.fund_grant)
    2.times do |i|
      e = first_fund_item.fund_editions.build_next_for_fund_request( @fund_request,
        { :amount => 100.0 } )
      e.save!
      e = second_fund_item.fund_editions.build_next_for_fund_request( @fund_request,
        { :amount => 100.0 } )
      e.save!
    end
    @fund_request.reload
    @fund_request.fund_items.length.should eql 2
    @fund_request.fund_editions.length.should eql 4
    @fund_request.fund_items.allocate!(150.0)
    @fund_request.fund_items.first.fund_allocations.first.amount.should eql 100
    @fund_request.fund_items.last.fund_allocations.first.amount.should eql 50
    @fund_request.fund_items.allocate!
    @fund_request.fund_items.first.fund_allocations.first.amount.should eql 100
    @fund_request.fund_items.last.fund_allocations.first.amount.should eql 100
    @fund_request.fund_items.allocate!(0.0)
    @fund_request.fund_items.first.fund_allocations.first.amount.should eql 0
    @fund_request.fund_items.last.fund_allocations.first.amount.should eql 0
    fund_tier = create :fund_tier, organization: @fund_request.fund_grant.fund_source.organization,
      maximum_allocation: 175.0
    @fund_request.fund_grant.fund_source.fund_tiers << fund_tier
    @fund_request.fund_grant.fund_tier = fund_tier; @fund_request.fund_grant.save!
    @fund_request.fund_items.allocate!
    @fund_request.fund_items.first.fund_allocations.first.amount.should eql 100
    @fund_request.fund_items.last.fund_allocations.first.amount.should eql 75
  end

  it 'should have an incomplete scope that returns fund_requests that have initial editions without final editions' do
    initial = create(:fund_edition)
    create(:fund_edition, :fund_request => initial.fund_request,
      :fund_item => initial.fund_item, :perspective => FundEdition::PERSPECTIVES.last )
    complete = initial.fund_request
    incomplete = create(:fund_edition).fund_request
    FundRequest.incomplete.should_not include complete
    FundRequest.incomplete.should include incomplete
  end

  it 'should have an can_approve? method that will not allow approval of started request unless all new items have an edition' do
    @fund_request.save!
    item = create(:fund_edition, :fund_request => @fund_request, :amount => 100.0).fund_item
    @fund_request.can_approve?.should be_true
    second_item = create(:fund_item, :fund_grant => @fund_request.fund_grant)
    @fund_request.reload
    @fund_request.can_approve?.should be_false
  end

  it 'should have an can_approve? method that will not allow approval of started request unless non-zero request item is included' do
    @fund_request.save!
    item = create(:fund_edition, :fund_request => @fund_request, :amount => 100.0).fund_item
    @fund_request.can_approve?.should be_true
    @fund_request.fund_editions.first.update_attribute :amount, 0.0
    @fund_request.can_approve?.should be_false
  end

  it 'should have an can_approve_review? method that will not allow approval of submitted requests unless all initial editions have corresponding finals' do
    queue = @fund_request.fund_grant.fund_source.fund_queues.first
    @fund_request.fund_queue = queue
    @fund_request.state = 'submitted'
    @fund_request.save!
    item = create(:fund_edition, :fund_request => @fund_request).fund_item
    @fund_request.reload
    @fund_request.can_approve_review?.should be_false
    item.reload
    item.fund_editions.build_next_for_fund_request( @fund_request ).save!
    @fund_request.reload
    @fund_request.can_approve_review?.should be_true
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

  it 'should have a duplicate scope' do
    @fund_request.save!
    @fund_request.update_attribute :state, 'submitted'
    duplicate = create(:fund_request, :fund_grant => @fund_request.fund_grant)
    different = create(:fund_request)
    duplicates = FundRequest.duplicate
    duplicates.count.should eql 2
    duplicates.should include @fund_request
    duplicates.should include duplicate
  end

  it 'should have a notify_unnotified! class method' do
    class FundRequest
      def require_requestor_recipients!
        return true
      end
    end
    other_state = create(:fund_request, :state => 'tentative')
    unnotified = create(:fund_request)
    notified_before = create(:fund_request)
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

  it 'should dissociate from a queue when withdrawn' do
    @fund_request.state = 'submitted'
    @fund_request.fund_queue = @fund_request.fund_grant.fund_source.fund_queues.first
    @fund_request.fund_queue.should_not be_nil
    @fund_request.save!
    @fund_request.withdrawn_by_user = create(:user)
    @fund_request.withdraw!
    @fund_request.fund_queue.should be_nil
  end

  it 'should dissociate from a queue when rejected' do
    @fund_request.state = 'submitted'
    @fund_request.fund_queue = @fund_request.fund_grant.fund_source.fund_queues.first
    @fund_request.fund_queue.should_not be_nil
    @fund_request.save!
    @fund_request.reject_message = 'some messsage'
    @fund_request.reject!
    @fund_request.fund_queue.should be_nil
  end

end

