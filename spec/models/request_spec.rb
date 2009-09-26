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

  it "should not save without an organization" do
    @request.organizations.delete_all
    @request.save.should == false
  end

  it "should not save with an invalid approval_checkpoint" do
    @request.save
    @request.approval_checkpoint = nil
    @request.save.should == false
  end

  it "should reset approval checkpoint on transition to submitted" do
    @request.save
    initial = @request.approval_checkpoint
    @request.reload
    first_approval = @request.approvals.create( :user => Factory(:user), :as_of => @request.updated_at )
    @request.reload
    @request.status.should == 'completed'
    sleep 1
    last = @request.approvals.create( :user => Factory(:user), :as_of => @request.updated_at )
    @request.reload
    initial.should_not == last.created_at
    @request.status.should == 'submitted'
    @request.approval_checkpoint.should > initial
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

  it "should have may_create? return false if basis is closed" do
    may_create = Factory(:permission, :action => 'create')
    basis = Factory(:basis, :framework => may_create.framework)
    request = Factory.build(:request, :basis => basis)
    user = Factory(:user)
    request.organizations.first.memberships.create( :user => user, :active => true, :role => may_create.role )
    request.basis.stub!(:open?).and_return(false)
    request.may_create?(user).should == false
    request.basis.stub!(:open?).and_return(true)
    request.may_create?(user).should == true
  end

  it "should have may_update? and may_destroy? return false if basis is closed" do
    admin = Factory(:user, :admin => true)
    may_update = Factory(:permission, :action => 'update')
    may_destroy = may_update.clone
    may_destroy.action = 'destroy'
    may_destroy.save
    basis = Factory(:basis, :framework => may_destroy.framework)
    request = Factory(:request, :basis => basis)
    user = Factory(:user)
    request.organizations.first.memberships.create( :user => user, :active => true, :role => may_update.role )
    request.basis.stub!(:open?).and_return(false)
    request.may_update?(user).should == false
    request.may_destroy?(user).should == false
    request.may_update?(admin).should == true
    request.may_destroy?(admin).should == true
    request.basis.stub!(:open?).and_return(true)
    request.may_update?(user).should == true
    request.may_destroy?(user).should == true
    request.may_update?(admin).should == true
    request.may_destroy?(admin).should == true
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

  it "should have an approvers.required_for_status which returns users required to approve" do
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
    approvers = request.approvers.required_for_status('completed')
    approvers.should include(president_one)
    approvers.should include(president_two)
    approvers.should include(treasurer)
    approvers.should include(commissioner)
    approvers.should_not include(wrong_president)
    approvers.should_not include(inactive_member)
    approvers.size.should == 4
  end

  it "should have an approvers.unfulfilled_for_status method which returns required approvers without corresponding approvals" do
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
      approval = request.approvals.create(:user => user, :as_of => request.updated_at)
    end
    request.approvers.stub!(:required_for_status).and_return( [ must_and_did, must_and_did_not ] )
    unfulfilled = request.approvers.unfulfilled_for_status(nil)
    unfulfilled.should_not include(must_and_did)
    unfulfilled.should include(must_and_did_not)
    unfulfilled.should_not include(did_but_not_must)
    unfulfilled.size.should == 1
  end

  it "should have approvers.potential_for?(approver) that returns users that count toward a particular approver requirement" do
    setup_approvers
    a1 = @request.approvers.potential_for(@c1)
    a1.should include(@p)
    a1.size.should == 1
    a2 = @request.approvers.potential_for(@c2)
    a2.should be_empty
    a3 = @request.approvers.potential_for(@c3)
    a3.should include(@c)
    a3.size.should == 1
  end

  it "should have approvers.actual_for?(approver)" do
    setup_approvers
    @request.organizations.first.memberships.create(:active => true, :user => @t, :role => @treasurer)
    @c4 = @request.framework.approvers.create( :perspective => 'reviewer', :status => 'reviewed', :role => @officer )
    sleep 1
    @request.approvals.create(:as_of => @request.updated_at, :user => @p)
    @request.reload
    @request.approvers.actual_for(@c1).should include(@p)
    @request.approvers.actual_for(@c1).size.should == 1
    @request.approvers.actual_for(@c2).should be_empty
    @request.reload
    @request.status.should == 'completed'
    @request.approvals.create(:as_of => @request.updated_at, :user => @o).id.should_not be_nil
    @request.reload
    @request.status.should == 'completed'
    @request.approvals.create(:as_of => @request.updated_at, :user => @t)
    @request.reload
    @request.status.should == 'submitted'
    sleep 1
    @request.accept.should == true
    @request.save.should == true
    @request.status.should == 'accepted'
    @request.save.should == true
    @request.approvals.create(:as_of => @request.updated_at, :user => @c).id.should_not be_nil
    @request.reload
    @request.status.should == 'reviewed'
    @request.approvers.actual_for(@c3).should include(@c)
    @request.approvers.actual_for(@c3).size.should == 1
    @request.approvers.actual_for(@c4).should be_empty
  end

  it "should call deliver_required_approval_notice on entering completed state" do
    @request.save
    @request.should_receive(:deliver_required_approval_notice)
    @request.approve.should == true
    @request.status.should == 'completed'
  end

  it "should call deliver_release_notice and set released_at on entering the completed state" do
    @request.status = 'certified'
    @request.save
    @request.should_receive(:deliver_release_notice)
    @request.released_at.should be_nil
    @request.release.should == true
    @request.released_at.should_not be_nil
    @request.status.should == 'released'
  end

  it "should set accepted_at on entering accepted state" do
    @request.status = 'submitted'
    @request.save
    @request.accepted_at.should be_nil
    @request.accept.should == true
    @request.accepted_at.should_not be_nil
  end

  it "should have items.allocate which enforces caps" do
    first_expense = Factory(:administrative_expense)
    first_version = first_expense.version
    first_version.amount = 100.0
    first_version.save
    first_item = first_version.item
    first_item.node.item_quantity_limit = 3
    first_item.node.save
    second_item = first_item.clone
    second_item.position = nil
    second_item.save
    second_item.versions.create( Factory.attributes_for(:version, :amount => 100.0, :administrative_expense_attributes => Factory.attributes_for(:administrative_expense) ) )
    first_item.versions.next.save.should == true
    second_item.versions.next.save.should == true
    request = first_item.request
    request.items.allocate(150.0)
    request.items.first.amount.should == 100.0
    request.items.last.amount.should == 50.0
    request.items.allocate(nil)
    request.items.first.amount.should == 100.0
    request.items.last.amount.should == 100.0
    request.items.allocate(0.0)
    request.items.first.amount.should == 0.0
    request.items.last.amount.should == 0.0
  end

  def setup_approvers
    @request.save.should == true
    @president = Role.create(:name => 'president')
    @treasurer = Role.create(:name => 'treasurer')
    @advisor = Role.create(:name => 'advisor')
    @commissioner = Role.create(:name => 'commissioner')
    @officer = Role.create(:name => 'officer')
    @p = Factory(:user); @a = Factory(:user); @t = Factory(:user); @c = Factory(:user); @o = Factory(:user);
    @c1 = @request.framework.approvers.create( :perspective => 'requestor', :status => 'completed', :role => @president )
    @c2 = @request.framework.approvers.create( :perspective => 'requestor', :status => 'completed', :role => @treasurer )
    @c3 = @request.framework.approvers.create( :perspective => 'reviewer', :status => 'reviewed', :role => @commissioner )
    @request.organizations.first.memberships.create(:active => true, :user => @p, :role => @president)
    @request.organizations.first.memberships.create(:active => true, :user => @a, :role => @advisor)
    @request.basis.organization.memberships.create(:active => true, :user => @t, :role => @treasurer)
    @request.basis.organization.memberships.create(:active => true, :user => @c, :role => @commissioner)
    @request.basis.organization.memberships.create(:active => true, :user => @o, :role => @officer )
  end

  def create_approver_for_request(request, role_name, perspective = 'requestor', status = 'completed')
    request.framework.approvers.create( :role => Role.find_or_create_by_name( role_name ),
      :perspective => perspective, :status => status ).id.should_not be_nil
  end

end

