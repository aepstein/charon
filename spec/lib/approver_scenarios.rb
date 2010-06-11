module SpecApproverScenarios

  def setup_approvers_scenario
    @framework = Factory(:framework)
    @quota_required ||= Factory(:role, :name => Role::REQUESTOR.first )
    @all_required ||= Factory(:role, :name => Role::REQUESTOR.last )
    @quota = Factory(:approver, :framework => @framework, :role => @quota_required, :quantity => 1, :status => 'completed')
    @all = Factory(:approver, :framework => @framework, :role => @all_required, :status => 'completed')
    @request = Factory(:request, :basis => Factory(:basis, :framework => @framework), :status => 'completed' )
    @request.approval_checkpoint = @request.created_at - 1.minute
    @request.save!
    requestor = @request.organization
    @quota_fulfilled = Factory(:membership, :role => @quota_required, :organization => requestor).user
    @quota_unfulfilled = Factory(:membership, :role => @quota_required, :organization => requestor).user
    @all_fulfilled = Factory(:membership, :role => @all_required, :organization => requestor).user
    @all_unfulfilled = Factory(:membership, :role => @all_required, :organization => requestor).user
  end

  def no_approvers_scenario(reset_checkpoint=false)
    setup_approvers_scenario
  end

  def half_approvers_scenario(reset_checkpoint=false)
    no_approvers_scenario
    Factory(:approval, :approvable => @request, :user => @quota_fulfilled )
    Factory(:approval, :approvable => @request, :user => @all_fulfilled )
  end

  def all_approvers_scenario(reset_checkpoint=false)
    half_approvers_scenario
    Factory(:approval, :approvable => @request, :user => @all_unfulfilled)
    @request.status = 'completed'
    @request.approval_checkpoint = (@request.created_at - 1.minute) if reset_checkpoint
    @request.save!
  end

  def no_reviewed_approvers_scenario(reset_checkpoint=false)
    all_approvers_scenario
    @request.status = 'reviewed'
    @request.save!
    @reviewer ||= Factory(:role, :name => Role::REVIEWER.first )
    @review = Factory(:approver, :framework => @framework, :role => @reviewer, :status => 'reviewed', :quantity => 1, :perspective => Edition::PERSPECTIVES.last )
    @reviewer_unfulfilled = Factory(:membership, :role => @reviewer, :organization => @request.basis.organization ).user
    Factory(:membership, :role => @reviewer, :organization => @request.basis.organization, :user => @all_fulfilled )
  end

  def all_reviewed_approvers_scenario(reset_checkpoint=false)
    no_reviewed_approvers_scenario
    approval_checkpoint = @request.approval_checkpoint
    sleep 1
    Factory(:approval, :approvable => @request, :user => @reviewer_unfulfilled)
    @request.status = 'reviewed'
    @request.approval_checkpoint = approval_checkpoint if reset_checkpoint
    @request.save!
  end

end

