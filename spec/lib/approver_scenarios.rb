module SpecApproverScenarios

  def setup_approvers_scenario
    @framework = Factory(:framework)
    quota_required = Factory(:role, :name => Role::REQUESTOR.first )
    all_required = Factory(:role, :name => Role::REQUESTOR.last )
    @quota = Factory(:approver, :framework => @framework, :role => quota_required, :quantity => 1, :status => 'completed')
    @all = Factory(:approver, :framework => @framework, :role => all_required, :status => 'completed')
    @request = Factory(:request, :basis => Factory(:basis, :framework => @framework), :status => 'completed' )
    requestor = @request.organization
    @quota_fulfilled = Factory(:membership, :role => quota_required, :organization => requestor).user
    @quota_unfulfilled = Factory(:membership, :role => quota_required, :organization => requestor).user
    @all_fulfilled = Factory(:membership, :role => all_required, :organization => requestor).user
    @all_unfulfilled = Factory(:membership, :role => all_required, :organization => requestor).user
    Factory(:approval, :approvable => @request, :user => @quota_fulfilled )
    Factory(:approval, :approvable => @request, :user => @all_fulfilled )
  end

end

