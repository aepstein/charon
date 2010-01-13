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

  it 'should have unsatisfied method that identifies permissions the user must satisfy requirements for' do
    setup_permission_scenario
    fulfillable = Factory(:agreement)
    @allowed_permission.requirements.create( :fulfillable => fulfillable )
    permissions = Permission.unsatisfied.memberships_user_id_eq(@allowed_member.user_id)
    permissions.length.should eql 1
    permissions.should include @allowed_permission
    @allowed_member.user.approvals.create(:approvable => fulfillable, :as_of => fulfillable.created_at + 1.day).id.should_not be_nil
    permissions = Permission.unsatisfied.memberships_user_id_eq(@allowed_member.user_id)
    permissions.to_a.should be_empty
  end

  it 'should have satisfied method that identifies permissions a user has fulfilled requirements for' do
    setup_permission_scenario
    fulfillable = Factory(:agreement)
    @allowed_permission.requirements.create( :fulfillable => fulfillable )
    permissions = Permission.satisfied.memberships_user_id_eq(@allowed_member.user_id)
    permissions.length.should eql 3
    permissions.should_not include @allowed_permission
    permissions.should_not include @permission_different_role
    permissions.should include @permission_different_status
    permissions.should include @permission_different_framework
    permissions.should include @permission_different_perspective
    @allowed_member.user.approvals.create(:approvable => fulfillable, :as_of => fulfillable.created_at + 1.day).id.should_not be_nil
    permissions = Permission.satisfied.memberships_user_id_eq(@allowed_member.user_id)
    permissions.length.should eql 4
    permissions.should include @allowed_permission
    permissions.should_not include @permission_different_role
    permissions.should include @permission_different_status
    permissions.should include @permission_different_framework
    permissions.should include @permission_different_perspective
    permissions.should include @allowed_permission
  end

  it 'should have satisfied method that identifies permissions the organization must satisfy requirements for' do
    setup_permission_scenario
    Factory(:registration, :organization => @allowed_member.organization)
    fulfillable = Factory(:registration_criterion, :must_register => true, :minimal_percentage => 0)
    @allowed_permission.requirements.create( :fulfillable => fulfillable )
    permissions = Permission.satisfied.memberships_organization_id_eq(@allowed_member.organization_id)
    permissions.length.should eql 3
    permissions.should_not include @allowed_permission
    permissions.should_not include @permission_different_role
    permissions.should include @permission_different_status
    permissions.should include @permission_different_framework
    permissions.should include @permission_different_perspective
    fulfillable.must_register = false
    fulfillable.save.should be_true
    @allowed_member.organization.fulfillments.length.should eql 1
    @allowed_member.organization.fulfillments.first.fulfillable.should eql fulfillable
    permissions = Permission.satisfied.memberships_organization_id_eq(@allowed_member.organization_id)
    permissions.length.should eql 4
    permissions.should include @allowed_permission
    permissions.should_not include @permission_different_role
    permissions.should include @permission_different_status
    permissions.should include @permission_different_framework
    permissions.should include @permission_different_perspective
    permissions.should include @allowed_permission
  end

  it 'should have unsatisfied method that identifies permissions the organization must satisfy requirements for' do
    setup_permission_scenario
    Factory(:registration, :organization => @allowed_member.organization)
    fulfillable = Factory(:registration_criterion, :must_register => true, :minimal_percentage => 0)
    @allowed_permission.requirements.create( :fulfillable => fulfillable )
    permissions = Permission.unsatisfied.memberships_organization_id_eq(@allowed_member.organization_id)
    permissions.length.should eql 1
    permissions.should include @allowed_permission
    fulfillable.must_register = false
    fulfillable.save.should be_true
    permissions = Permission.unsatisfied.memberships_organization_id_eq(@allowed_member.organization_id)
    permissions.to_a.should be_empty
  end

  it 'should have perspectives_in method that identifies permissions with a perspective matching an organization' do
    setup_permission_scenario
    permissions = Permission.perspectives_in([['requestor',@allowed_member.organization_id]]
      ).memberships_user_id_eq(@allowed_member.user_id)
    permissions.length.should eql 3
    permissions.should include @allowed_permission
    permissions.should include @permission_different_status
    permissions.should include @permission_different_framework
    permissions = Permission.perspectives_in([['reviewer',@allowed_member.organization_id]]
      ).memberships_user_id_eq(@allowed_member.user_id)
    permissions.length.should eql 1
    permissions.should include @permission_different_perspective
  end

  def setup_permission_scenario
    @request = Factory(:request)
    @allowed_organization = @request.organizations.first
    @allowed_status = @request.status
    @allowed_role = Factory(:role)
    @allowed_member = Factory( :membership, :active => true, :organization => @allowed_organization, :role => @allowed_role )
    @allowed_framework = @request.basis.framework
    @allowed_permission = Factory( :permission, :framework => @allowed_framework,
      :role => @allowed_role, :status => @allowed_status, :perspective => 'requestor' )
    @permission_different_role = Factory( :permission, :framework => @allowed_framework,
      :role => Factory(:role), :status => @allowed_status, :perspective => 'requestor' )
    @permission_different_role.role.should_not eql @allowed_role
    @permission_different_status = Factory( :permission, :framework => @allowed_framework,
      :role => @allowed_role, :status => 'completed', :perspective => 'requestor' )
    @permission_different_status.should_not eql @allowed_status
    @permission_different_framework = Factory( :permission, :framework => Factory(:framework),
      :role => @allowed_role, :status => @allowed_status, :perspective => 'requestor' )
    @permission_different_framework.framework.should_not eql @allowed_permission.framework
    @permission_different_perspective = Factory( :permission, :framework => @allowed_framework,
      :role => @allowed_role, :status => @allowed_status, :perspective => 'reviewer' )
    @permission_different_perspective.perspective.should_not eql @allowed_permission.perspective
    @inactive_member = Factory(:membership, :role => @allowed_member.role, :active => false,
      :organization => @allowed_organization, :role => @allowed_role )
    @wrong_organization_member = Factory(:membership, :role => @allowed_member.role,
      :active => false, :organization => Factory(:organization), :role => @allowed_role )
    @wrong_role_member = Factory(:membership, :role => Factory(:role), :active => false, :organization => @allowed_organization )
  end

end

