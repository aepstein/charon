module SpecApproverScenarios

  def setup_approvers_scenario
    @framework = Factory(:framework)
    @quota_required ||= Factory(:role, :name => Role::REQUESTOR.first )
    @all_required ||= Factory(:role, :name => Role::REQUESTOR.last )
    @quota = Factory(:approver, :framework => @framework, :role => @quota_required, :quantity => 1)
    @all = Factory(:approver, :framework => @framework, :role => @all_required)
    @fund_grant = Factory(:fund_grant, :fund_source => Factory(:fund_source, :framework => @framework))
    @fund_request = Factory(:fund_request, :fund_grant => @fund_grant)
    @fund_request.approval_checkpoint = @fund_request.created_at - 1.minute
    @fund_request.save!
    fund_requestor = @fund_grant.organization
    @quota_fulfilled = Factory(:membership, :role => @quota_required, :organization => fund_requestor).user
    @quota_unfulfilled = Factory(:membership, :role => @quota_required, :organization => fund_requestor).user
    @all_fulfilled = Factory(:membership, :role => @all_required, :organization => fund_requestor).user
    @all_unfulfilled = Factory(:membership, :role => @all_required, :organization => fund_requestor).user
  end

  def no_approvers_scenario(reset_checkpoint=false)
    setup_approvers_scenario
  end

  def half_approvers_scenario(reset_checkpoint=false)
    no_approvers_scenario
    Factory(:approval, :approvable => @fund_request, :user => @quota_fulfilled )
    Factory(:approval, :approvable => @fund_request, :user => @all_fulfilled )
  end

  def all_approvers_scenario(reset_checkpoint=false)
    half_approvers_scenario
    Factory(:approval, :approvable => @fund_request, :user => @all_unfulfilled)
    @fund_request.state = 'tentative'
    @fund_request.approval_checkpoint = (@fund_request.created_at - 1.minute) if reset_checkpoint
    @fund_request.save!
  end

  def no_reviewed_approvers_scenario(reset_checkpoint=false)
    all_approvers_scenario
    @fund_request.review_state = 'tentative'
    @fund_request.save!
    @reviewer ||= Factory(:role, :name => Role::REVIEWER.first )
    @review = Factory(:approver, :framework => @framework, :role => @reviewer, :quantity => 1, :perspective => FundEdition::PERSPECTIVES.last )
    @reviewer_unfulfilled = Factory(:membership, :role => @reviewer, :organization => @fund_grant.fund_source.organization ).user
    Factory(:membership, :role => @reviewer, :organization => @fund_grant.fund_source.organization, :user => @all_fulfilled )
  end

  def all_reviewed_approvers_scenario(reset_checkpoint=false)
    no_reviewed_approvers_scenario
    approval_checkpoint = @fund_request.approval_checkpoint
    sleep 1
    Factory(:approval, :approvable => @fund_request, :user => @reviewer_unfulfilled)
    @fund_request.review_state = 'tentative'
    @fund_request.approval_checkpoint = approval_checkpoint if reset_checkpoint
    @fund_request.save!
  end

end

