require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @request = Factory.build(:request)
    #@request.organizations << Factory(:organization)
  end

  it "should create a new instance given valid attributes" do
    @request.organizations.each do |organization|
      @request.organizations.allowed?(organization).should == true
    end
    @request.save.should == true
  end

  it "should not create a new instance after a basis has closed" do
    request = Factory.build(:request)
    request.basis.open_at = DateTime.now - 2.days
    request.basis.closed_at = DateTime.now - 1.days
    request.basis.save.should == true
    request.save.should == false
  end

  it "should not save without an organization" do
    @request.organizations.delete_all
    @request.save.should == false
  end

  it "should have a may method for retrieving a user's permissions in framework" do
    allowed_role = Factory(:role, :name => 'allowed')
    disallowed_role = Factory(:role, :name => 'disallowed')
    allowed_user = Factory(:user)
    disallowed_user = Factory(:user)
    @request.framework.permissions.create( :role => allowed_role,
      :action => Request::ACTIONS.first, :perspective => Version::PERSPECTIVES.first,
      :status => Request.aasm_initial_state.to_s )
    organization = @request.send(Version::PERSPECTIVES.first.pluralize).first
    organization.memberships.create( :user => allowed_user,
      :role => allowed_role, :active => true ).id.should_not be_nil
    organization.memberships.create( :user => disallowed_user,
      :role => disallowed_role, :active => true ).id.should_not be_nil
    @request.may(allowed_user).size.should == 1
    @request.may(allowed_user).first.should == Request::ACTIONS.first
    @request.may(disallowed_user).should be_empty
  end

  it "should have a retriever method for each perspective" do
    request = Factory(:request)
    Version::PERSPECTIVES.each do |perspective|
      organizations = request.send(perspective.pluralize)
      organizations.size.should > 0
      organizations.each do |organization|
        organization.class.should == Organization
      end
    end
  end

  it "should allow the administrator to take any action" do
    admin = Factory(:user, :admin => true)
    Factory(:request).may(admin).should == Request::ACTIONS
  end

end

