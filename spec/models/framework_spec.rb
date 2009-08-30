require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Framework do
  before(:each) do
    @framework = Factory(:framework)
  end

  it "should create a new instance given valid attributes" do
    @framework.id.should_not be_nil
  end

  it "should not save without a name" do
    @framework.name = ""
    @framework.save.should == false
  end

  it "should not save with a name that is not unique" do
    second_framework = Factory.build(:framework,:name => @framework.name)
    second_framework.save.should == false
  end

  it "should not save without a must_register setting" do
    @framework.must_register = nil
    @framework.save.should == false
  end

  it "should not save if member_percentage or member_percentage_type are set, but not both valid" do
    @framework.member_percentage = 10
    @framework.save.should == false
    @framework.member_percentage_type = Registration::MEMBER_TYPES.first
    @framework.member_percentage_type?.should == true
    @framework.member_percentage_type.empty?.should == false
    @framework.member_percentage = nil
    @framework.save.should == false
    @framework.member_percentage = 10
    @framework.member_percentage_type = 'invalid'
    Registration::MEMBER_TYPES.should_not include( @framework.member_percentage_type )
    @framework.save.should == false
    @framework.member_percentage_type = Registration::MEMBER_TYPES.first
    @framework.member_percentage = 101
    @framework.save.should == false
    @framework.member_percentage = 0
    @framework.save.should == false
    @framework.member_percentage = 50
    @framework.save.should == true
  end

  it "should have a permissions.allowed_actions(roles,perspective,status) that returns allowed actions only" do
    agreement = Factory(:agreement)
    allowed_user = Factory(:user)
    allowed_user.approvals.create(:approvable => agreement, :as_of => agreement.updated_at)
    disallowed_user = Factory(:user)
    allowed_role = Factory(:role)
    disallowed_role = Factory(:role)
    allowed_role.should_not == disallowed_role
    allowed_perspective = Version::PERSPECTIVES.first
    disallowed_perspective = Version::PERSPECTIVES.last
    allowed_perspective.should_not == disallowed_perspective
    allowed_status = Request.aasm_states.first.name.to_s
    disallowed_status = Request.aasm_states.last.name.to_s
    allowed_status.should_not == disallowed_status
    allowed_action = Request::ACTIONS.first
    disallowed_action = Request::ACTIONS.last
    allowed_action.should_not == disallowed_action
    permission = @framework.permissions.create( :role => allowed_role,
      :perspective => allowed_perspective, :status => allowed_status, :action => allowed_action )
    permission.id.should_not be_nil
    permission.agreements << agreement
    allowed_actions = @framework.permissions.allowed_actions(allowed_user,[allowed_role], allowed_perspective, allowed_status)
    allowed_actions.size.should == 1
    allowed_actions.first.should == allowed_action
    @framework.permissions.allowed_actions(allowed_user,[disallowed_role], allowed_perspective, allowed_status).should be_empty
    @framework.permissions.allowed_actions(disallowed_user,[allowed_role], allowed_perspective, allowed_status).should be_empty
    @framework.permissions.allowed_actions(allowed_user,[allowed_role], disallowed_perspective, allowed_status).should be_empty
    @framework.permissions.allowed_actions(allowed_user,[allowed_role], allowed_perspective, disallowed_status).should be_empty
    @framework.permissions.allowed_actions(allowed_user,[], allowed_perspective, allowed_status).should be_empty
  end

  it "should include the GlobalModelAuthorization module" do
    Framework.included_modules.should include(GlobalModelAuthorization)
  end

  it "should have a member_requirement method that returns a string representation of the memberhsip requirement" do
    framework = Factory(:framework)
    framework.member_percentage = 50
    framework.member_percentage_type = Registration::MEMBER_TYPES.first
    framework.valid?.should == true
    framework.member_requirement.should ==
      "#{framework.member_percentage}% #{Registration::MEMBER_TYPES.first}"
  end
end

