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

  it "should have an approvers.required_for which returns users required to approve" do
    request = Factory(:request)
    %w( president treasurer ).each { |role_name| create_approver_for_request(request, role_name) }
    %w( commissioner staff ).each { |role_name| create_approver_for_request(request, role_name, 'reviewer') }
    president_one = Factory(:user)
    president_two = Factory(:user)
    wrong_president = Factory(:user)
    treasurer = Factory(:user)
    commissioner = Factory(:user)
    inactive_member = Factory(:user)
    requestor = request.organizations.first
    reviewer = request.basis.organization
    requestor.memberships.create( :active => true, :user => president_one, :role => Role.find_by_name('president') )
    requestor.memberships.create( :active => true, :user => president_two, :role => Role.find_by_name('president') )
    requestor.memberships.create( :active => true, :user => treasurer, :role => Role.find_by_name('treasurer') )
    reviewer.memberships.create( :active => true, :user => wrong_president, :role => Role.find_by_name('president') )
    reviewer.memberships.create( :active => true, :user => commissioner, :role => Role.find_by_name('commissioner') )
    reviewer.memberships.create( :active => false, :user => inactive_member, :role => Role.find_by_name('commissioner') )
    approvers = request.approvers.required_for('completed')
    approvers.should include(president_one)
    approvers.should include(president_two)
    approvers.should include(treasurer)
    approvers.should include(commissioner)
    approvers.should_not include(wrong_president)
    approvers.should_not include(inactive_member)
    approvers.size.should == 4
  end

  it "should have an approvers.unfulfilled method which returns required approvers without corresponding approvals" do
    must_and_did = Factory(:user)
    must_and_did_not = Factory(:user)
    did_but_not_must = Factory(:user)
    request = Factory(:request)
    role = Factory(:role)
    [ must_and_did, must_and_did_not ].each do |user|
      request.organizations.first.memberships.create(
        :role => role,
        :user => user,
        :active => true
      )
    end
    request.framework.approvers.create( :perspective => 'requestor', :status => 'started', :role => role )
    [ must_and_did, did_but_not_must ].each do |user|
      approval = request.approvals.create(:user => user)
    end
    request.approvers.stub!(:required_for).and_return( [ must_and_did, must_and_did_not ] )
    unfulfilled = request.approvers.unfulfilled_for(nil)
    unfulfilled.should_not include(must_and_did)
    unfulfilled.should include(must_and_did_not)
    unfulfilled.should_not include(did_but_not_must)
    unfulfilled.size.should == 1
  end

  def create_approver_for_request(request, role_name, perspective = 'requestor', status = 'completed')
    request.framework.approvers.create( :role => Role.find_or_create_by_name( role_name ),
      :perspective => perspective, :status => status ).id.should_not be_nil
  end

end

