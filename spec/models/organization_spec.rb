require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  before(:each) do
    @organization = Factory(:organization)
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })
  end

  it "should create a new instance given valid attributes" do
    Factory(:organization).new_record?.should == false
  end

  it "should have a requests.creatable method that returns requests that can be made" do
    basis = Factory(:basis)
    started_request = Factory(:request, :organizations => [@organization])
    closed_basis = Factory(:basis, :open_at => DateTime.now - 1.year, :closed_at => DateTime.now - 1.day)
    requests = @organization.requests.creatable
    requests.length.should == 1
    requests.first.class.should == Request
    requests.first.basis.should eql basis
  end

  it "should have a requests.started method that returns started requests" do
    request = Factory.build(:request)
    request.organizations << @registered_organization
    request.save.should == true
    @registered_organization.requests.should include(request)
    @registered_organization.requests.started.empty?.should == false
  end

  it "should have a requests.released method that returns released requests" do
    request = Factory.build(:request, { :status => "released" })
    request.organizations << @registered_organization
    request.save.should == true
    @registered_organization.requests.should include(request)
    @registered_organization.requests.released.empty?.should == false
  end

  it "should reformat last_name of organizations such that An|A|The|Cornell are moved to first_name" do
    organization = Factory(:organization)
    parameters = {
      "A Club" => { :first => "A", :last => "Club" },
      "An Club" => { :first => "An", :last => "Club" },
      "The Club" => { :first => "The", :last => "Club" },
      "Cornell Club" => { :first => "Cornell", :last => "Club" },
      "The Cornell Club" => { :first => "The Cornell", :last => "Club" },
      "club" => { :first => "", :last => "club" }
    }
    parameters.each do |last_name, results|
      organization.last_name = last_name
      organization.save.should == true
      organization.first_name.should == results[:first]
      organization.last_name.should == results[:last]
      organization.first_name = "" && organization.last_name == ""
    end
  end

  it "should have a registered? method that checks whether the current registration is approved" do
    @registered_organization.registered?.should == true
    Factory(:organization).registered?.should == false
  end

  it 'should have unfulfilled_permissions method that returns permissions the user cannot have because of missing requirements' do
    setup_permission_scenario
    permissions = @membership.organization.unfulfilled_permissions
    permissions.length.should eql 2
    permissions.should include @unfulfilled_permission_user
    permissions.should include @unfulfilled_permission_organization
  end

  it 'should have unfulfilled_requirements method that returns hash of unfulfilled requirements and associated permissions' do
    setup_permission_scenario
    requirements = @membership.organization.unfulfilled_requirements
    requirements.length.should eql 2
    requirements.should include @user_requirement
    requirements.should include @organization_requirement
    requirements[@user_requirement].should include @unfulfilled_permission_user
    requirements[@organization_requirement].should include @unfulfilled_permission_organization
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

