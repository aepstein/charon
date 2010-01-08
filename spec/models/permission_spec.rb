require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:permission).id.should_not be_nil
  end

  it "should not save without a role" do
    permission = Factory(:permission)
    permission.role = nil
    permission.save.should == false
  end

  it "should not save without a framework" do
    permission = Factory(:permission)
    permission.framework = nil
    permission.save.should == false
  end

  it "should not save with an invalid or absent perspective" do
    permission = Factory(:permission)
    permission.perspective = nil
    permission.save.should == false
    permission.perspective = "invalid"
    Edition::PERSPECTIVES.should_not include(permission.perspective)
    permission.save.should == false
  end

  it "should not save with an invalid action" do
    permission = Factory(:permission)
    permission.action = nil
    permission.save.should == false
    permission.action = 'invalid'
    Request::ACTIONS.should_not include(permission.action)
    permission.save.should == false
  end

  it "should not save with a missing or invalid status" do
    permission = Factory(:permission)
    permission.status = nil
    permission.save.should == false
    permission.status = 'invalid'
    Request.aasm_state_names.should_not include(permission.status)
    permission.save.should == false
  end

  it "should have may_create? that returns framework.may_update?" do
    permission = Factory.build(:permission)
    permission.framework.stub!(:may_update?).and_return('may_update')
    permission.may_create?(nil).should == 'may_update'
  end

  it "should have may_update? that returns framework.may_update?" do
    permission = Factory(:permission)
    permission.framework.stub!(:may_update?).and_return('may_update')
    permission.may_update?(nil).should == 'may_update'
  end

  it "should have may_destroy? that returns framework.may_update?" do
    permission = Factory(:permission)
    permission.framework.stub!(:may_update?).and_return('may_update')
    permission.may_destroy?(nil).should == 'may_update'
  end

  it "should have a may_see? that returns framework.may_see?" do
    permission = Factory(:permission)
    permission.framework.stub!(:may_see?).and_return('may_see')
    permission.may_see?(nil).should == 'may_see'
  end

  it 'should have with_user_id(user_id) that returns only permissions relevant to a user' do
    setup_permission_scenario
    permissions = Permission.with_memberships.with_user_id( @allowed_member.user_id)
    permissions.size.should eql 3
    permissions.should include @allowed_permission
    permissions.should include @permission_different_perspective
    permissions.should include @permission_different_framework
    Permission.with_memberships.with_user_id( @inactive_member.user_id ).should be_empty
    Permission.with_memberships.with_user_id( @wrong_organization_member.user_id ).should be_empty
    Permission.with_memberships.with_user_id( @wrong_role_member.user_id ).should be_empty
  end

  it 'should have with_request_id(request_id) that returns only permissions relevant to a request' do
    setup_permission_scenario
    permissions = Permission.with_memberships.with_bases.with_request_id( @request.id )
    permissions.size.should eql 1
    permissions.should include @allowed_permission
    @allowed_member.destroy
    Permission.with_memberships.with_bases.with_request_id( @request.id ).should be_empty
  end

  it 'should have a with_request_parameters(basis_id, status, organization_ids) that returns only permissions relevant to a new request' do
    setup_permission_scenario
    organization_ids = @request.organization_ids
    permissions = Permission.with_memberships.with_bases.with_request_parameters( @request.basis_id, @request.status, organization_ids )
    permissions.size.should eql 1
    permissions.should include @allowed_permission
    @request.destroy
    permissions = Permission.with_memberships.with_bases.with_request_parameters( @request.basis_id, @request.status, organization_ids )
    permissions.size.should eql 1
    permissions.should include @allowed_permission
  end

  it 'should have fulfilled_for and unfulfilled_for methods that identify permissions a user has fulfilled requirements for' do
    setup_permission_scenario
    fulfillable = Factory(:agreement)
    @allowed_permission.requirements.create( :fulfillable => fulfillable )
    Permission.fulfilled_for( @allowed_member.user, @request ).to_a.should be_empty
    @allowed_member.user.approvals.create(:approvable => fulfillable, :as_of => fulfillable.created_at + 1.day).id.should_not be_nil
    permissions = Permission.fulfilled_for( @allowed_member.user, @request )
    permissions.to_a.size.should eql 1
    permissions.should include @allowed_permission
  end

  it 'should have unfulfilled_for method that identifies permissions the user has fulfilled requirements for in context' do
    setup_permission_scenario
    fulfillable = Factory(:agreement)
    @allowed_permission.requirements.create( :fulfillable => fulfillable )
    permissions = Permission.unfulfilled_for( @allowed_member.user, @request ).to_a
    permissions.size.should eql 1
    permissions.should include @allowed_permission
    @allowed_member.user.approvals.create(:approvable => fulfillable, :as_of => fulfillable.created_at + 1.day).id.should_not be_nil
    permissions = Permission.unfulfilled_for( @allowed_member.user, @request )
    permissions.to_a.should be_empty
  end

  def setup_permission_scenario
    @request = Factory(:request)
    @allowed_organization = @request.organizations.first
    @allowed_status = @request.status
    @allowed_role = Factory(:role)
    @allowed_member = Factory( :membership, :active => true, :organization => @allowed_organization, :role => @allowed_role )
    @allowed_permission = Factory( :permission, :framework => @request.basis.framework,
      :role => @allowed_role, :status => @allowed_status, :perspective => 'requestor' )
    @permission_different_role = Factory( :permission, :framework => @request.basis.framework, :perspective => 'requestor' )
    @permission_different_role.role.should_not eql @allowed_role
    @permission_different_status = Factory( :permission, :framework => @request.basis.framework, :status => 'completed',
      :perspective => 'requestor' )
    @permission_different_status.should_not eql @allowed_status
    @permission_different_framework = Factory( :permission, :role => @allowed_role, :status => @allowed_status,
      :perspective => 'requestor' )
    @permission_different_framework.framework.should_not eql @allowed_permission.framework
    @permission_different_perspective = Factory( :permission, :framework => @request.basis.framework, :role => @allowed_role,
      :status => @allowed_status, :perspective => 'reviewer' )
    @permission_different_perspective.perspective.should_not eql @allowed_permission.perspective
    @inactive_member = Factory(:membership, :role => @allowed_member.role, :active => false,
      :organization => @allowed_organization, :role => @allowed_role )
    @wrong_organization_member = Factory(:membership, :role => @allowed_member.role,
      :active => false, :organization => Factory(:organization), :role => @allowed_role )
    @wrong_role_member = Factory(:membership, :role => Factory(:role), :active => false, :organization => @allowed_organization )
  end

end

