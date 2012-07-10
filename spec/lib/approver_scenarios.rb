module SpecApproverScenarios

  def setup_approvers_scenario
    @framework = create(:framework)
    @quota_required ||= create(:role, :name => Role::REQUESTOR.first )
    @all_required ||= create(:role, :name => Role::REQUESTOR.last )
    @quota = create(:approver, :framework => @framework, :role => @quota_required, :quantity => 1)
    @all = create(:approver, :framework => @framework, :role => @all_required)
    @fund_source = create(:fund_source, :framework => @framework)
    @fund_queue = create(:fund_queue, :fund_source => @fund_source)
    @fund_source.fund_queues.reset
    @fund_grant = create(:fund_grant, :fund_source => @fund_source)
    @fund_request = create(:fund_request, :fund_grant => @fund_grant)
    @fund_request.approval_checkpoint = @fund_request.created_at - 1.minute
    @fund_request.save!
    requestor = @fund_grant.organization
    @quota_fulfilled = create(:membership, :role => @quota_required, :organization => requestor).user
    @quota_unfulfilled = create(:membership, :role => @quota_required, :organization => requestor).user
    @all_fulfilled = create(:membership, :role => @all_required, :organization => requestor).user
    @all_unfulfilled = create(:membership, :role => @all_required, :organization => requestor).user
  end

  def no_approvers_scenario(reset_checkpoint=false)
    setup_approvers_scenario
    @fund_request.state = 'tentative'
  end

  def half_approvers_scenario(reset_checkpoint=false)
    no_approvers_scenario
    create(:approval, approvable: @fund_request, user: @quota_fulfilled )
    create(:approval, approvable: @fund_request, user: @all_fulfilled )
  end

  def all_approvers_scenario(reset_checkpoint=false)
    half_approvers_scenario
    create(:approval, :approvable => @fund_request, :user => @all_unfulfilled)
    @fund_request.state = 'tentative'
    @fund_request.approval_checkpoint = (@fund_request.created_at - 1.minute) if reset_checkpoint
    @fund_request.save!
  end

  def no_reviewed_approvers_scenario(reset_checkpoint=false)
    all_approvers_scenario
    @fund_request.submit!
    @fund_request.review_state = 'tentative'
    @fund_request.save!
    @reviewer ||= create(:role, :name => Role::REVIEWER.first )
    @review = create(:approver, :framework => @framework, :role => @reviewer, :quantity => 1, :perspective => FundEdition::PERSPECTIVES.last )
    @reviewer_unfulfilled = create(:membership, :role => @reviewer, :organization => @fund_grant.fund_source.organization ).user
    create(:membership, :role => @reviewer, :organization => @fund_grant.fund_source.organization, :user => @all_fulfilled )
  end

  def all_reviewed_approvers_scenario(reset_checkpoint=false)
    no_reviewed_approvers_scenario
    approval_checkpoint = @fund_request.approval_checkpoint
    sleep 1
    create(:approval, :approvable => @fund_request, :user => @reviewer_unfulfilled)
    @fund_request.review_state = 'tentative'
    @fund_request.approval_checkpoint = approval_checkpoint if reset_checkpoint
    @fund_request.save!
  end

end

