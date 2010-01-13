require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @admin = Factory(:user, :admin => true)
    @regular = Factory(:user)
  end

  it "should save a valid user" do
    Factory(:user).id.should_not be_nil
  end

  it "should have a organizations method that returns organizations related by active memberships" do
    user = Factory(:user)
    active = user.memberships.create( :role => Factory(:role), :organization => Factory(:organization), :active => true )
    inactive = user.memberships.create( :role => Factory(:role), :organization => Factory(:organization), :active => false )
    user.organizations.size.should == 1
    user.organizations.should include(active.organization)
    user.organizations.should_not include(inactive.organization)
  end

  it "should have a may_create? which only allows admin" do
    owner = Factory.build(:user)
    owner.may_create?(@admin).should == true
    owner.may_create?(owner).should == false
    owner.may_create?(@regular).should == false
  end

  it "should have a may_see? which allows admin or owner" do
    owner = Factory(:user)
    owner.may_see?(@admin).should == true
    owner.may_see?(@regular).should == false
    owner.may_see?(owner).should == true
  end

  it "should have a may_update? which allows admin or owner" do
    owner = Factory(:user)
    owner.may_update?(@admin).should == true
    owner.may_update?(@regular).should == false
    owner.may_update?(owner).should == true
  end

  it "should have a may_destroy? which only allows admin" do
    owner = Factory(:user)
    owner.may_destroy?(@admin).should == true
    owner.may_destroy?(@regular).should == false
    owner.may_destroy?(owner).should == false
  end

  it 'should automatically fulfill user status criterions on create and update' do
    criterion = Factory(:user_status_criterion, :statuses => %w( staff faculty ) )
    criterion2 = Factory(:user_status_criterion, :statuses => %w( temporary ) )
    user = Factory(:user, :status => 'staff')
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql criterion
    user.status = 'temporary'
    user.save.should be_true
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql criterion2
  end

  it 'should have unfulfilled_permissions method that returns permissions the user cannot have because of missing requirements' do
    setup_permission_scenario
    permissions = @membership.user.unfulfilled_permissions
    permissions.length.should eql 1
    permissions.should include @unfulfilled_permission_user
  end

  it 'should have unfulfilled_requirements method that returns hash of unfulfilled requirements and associated permissions' do
    setup_permission_scenario
    requirements = @membership.user.unfulfilled_requirements
    requirements.length.should eql 1
    requirements.should include @user_requirement
    requirements[@user_requirement].should include @unfulfilled_permission_user
  end

  def setup_permission_scenario
    Permission.delete_all
    @membership = Factory(:membership)
    @fulfilled_permission = Factory(:permission, :role => @membership.role)
    @unfulfilled_permission_organization = Factory(:permission, :role => @membership.role)
    @organization_requirement = Factory(:registration_criterion)
    Factory(:requirement, :fulfillable => @organization_requirement, :permission => @unfulfilled_permission_organization)
    @membership.organization.fulfillments.should be_empty
    @unfulfilled_permission_user = Factory(:permission, :role => @membership.role)
    @user_requirement = Factory(:user_status_criterion, :statuses => ['temporary'])
    @user_requirement.id.should_not be_nil
    Factory(:requirement, :fulfillable => @user_requirement, :permission => @unfulfilled_permission_user )
    @membership.user.fulfillments.should be_empty
  end

end

