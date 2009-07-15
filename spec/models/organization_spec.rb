require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })
  end

  it "should create a new instance given valid attributes" do
    Factory(:organization).new_record?.should == false
  end

  it "should be safc_eligible if given a safc-eligible, active registration" do
    @registered_organization.registrations.first.update_attributes( { :number_of_undergrads => 60 } )
    @registered_organization.registrations.first.safc_eligible?.should == true
    @registered_organization.registrations.first.active?.should == true
    @registered_organization.safc_eligible?.should == true
  end

  it "should be safc_eligible if given a gpsafc-eligible, active registration" do
    registration = Factory(:registration)
    @registered_organization.registrations.first.update_attributes( { :number_of_grads => 40 } )
    @registered_organization.registrations.first.gpsafc_eligible?.should == true
    @registered_organization.registrations.first.active?.should == true
    @registered_organization.gpsafc_eligible?.should == true
  end

  it "should have a requests.creatable method that returns requests that can be made" do
    basis = Factory(:basis)
    Basis.open.no_draft_request_for(@registered_organization).should include(basis)
    basis.eligible_to_request?(@registered_organization).should == true
    @registered_organization.requests.creatable.size.should == 1
    @registered_organization.requests.creatable.first.class.should == Request
  end

  it "should have a requests.draft method that returns draft requests" do
    request = Factory.build(:request)
    request.organizations << @registered_organization
    request.save.should == true
    @registered_organization.requests.should include(request)
    @registered_organization.requests.draft.empty?.should == false
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
end

