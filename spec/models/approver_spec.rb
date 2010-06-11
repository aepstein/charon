require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Approver do
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

  it 'should have an fulfilled_for scope that returns unfulfilled approver conditions' do
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

