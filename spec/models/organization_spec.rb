require 'spec_helper'
require 'shared_examples/fulfiller_examples'
require 'shared_examples/notifiable_examples'

describe Organization do

  let(:organization) { build :organization }
  let(:registered_organization) { build :registered_organization }

  it "should create a new instance given valid attributes" do
    organization.save!
  end

  it 'should not save without a last_name' do
    organization.last_name = nil
    organization.save.should be_false
  end

  it "should reformat last_name of organizations such that An|A|The|Cornell are moved to first_name" do
    parameters = {
      "A Club" => %w( A Club ),
      "An Club" => %w( An Club ),
      "The Club" => %w( The Club ),
      "Cornell Club" => %w( Cornell Club ),
      "The Cornell Club" => [ "The Cornell", "Club" ],
      "club" => [ "", "club" ]
    }
    parameters.each do |last_name, results|
      organization.last_name = last_name
      organization.save.should be_true
      organization.first_name.should eql results.first
      organization.last_name.should eql results.last
      organization.first_name = "" && organization.last_name = ""
    end
  end

  it "should have a registered? method that checks whether the current registration is approved" do
    registered_organization.save!
    registered_organization.registrations.first.current?.should be_true
    registered_organization.registrations.first.registered?.should be_true
    registered_organization.registrations.count.should eql 1
    Registration.current.count.should eql 1
    registered_organization.current_registration.should_not be_blank
    registered_organization.registered?.should be_true
    create(:organization).registered?.should be_false
  end

  context 'memberships' do

    it "should destroy associated memberships without registration on destroy" do
      membership = create(:membership)
      membership.organization.destroy
      Membership.all.should_not include membership
    end

    it "should nullify associated memberships with registration on destroy" do
      registered_organization.save!
      membership = create( :membership, organization: registered_organization,
        registration: registered_organization.registrations.first,
        active: true )
      registered_organization.destroy
      Membership.all.should include membership
      Membership.where { organization_id.eq( nil ) }.should include membership
    end

  end

  context 'require_requestor_recipients!' do
    it 'should have require_requestor_recipients! return true if at least one requestor user is present' do
      organization.save!
      create(:membership, role: create(:requestor_role),
        organization: organization )
      organization.association(:users).reset
      organization.users.should_not be_empty
      organization.require_requestor_recipients!.should be_true
    end

    it 'should have require_requestor_recipients! return false and send ' +
      'registration_required_notice if no requestor users are present' do
      organization.save!
      organization.users.should be_empty
      organization.should_receive :send_registration_required_notice!
      organization.require_requestor_recipients!.should be_false
    end
  end

  context 'fulfiller' do
    let(:fulfillable_types) { %w( RegistrationCriterion ) }
    include_examples 'fulfiller module'
  end

  context 'registration_criterion fulfiller with registered' do
    include_examples 'fulfiller update_frameworks'

    let(:framework) { create :framework,
      requirements: [ build( :requirement,
        fulfillable: create( :registration_criterion, must_register: true
    ) ) ] }
    let(:fulfiller) { create( :current_registration, registered: true,
      organization: create( :organization ) ).organization }
    let(:unfulfiller) { create( :current_registration, registered: false,
      organization: create( :organization ) ).organization }

    def fulfill(f); f.current_registration.registered = true; f.current_registration.save!; end
    def unfulfill(f); f.current_registration.registered = false; f.current_registration.save!; end
    def fulfiller_to_membership(f); f.current_registration; end
    def fulfiller_to_reflection(f); f.current_registration.organization; end
    def build_membership; build :registered_membership; end
  end

  context 'registration_criterion fulfiller with composition' do
    include_examples 'fulfiller update_frameworks'

    let(:framework) { create :framework,
      requirements: [ build( :requirement,
        fulfillable: create( :registration_criterion, must_register: false,
          minimal_percentage: 50, type_of_member: 'undergrads'
    ) ) ] }
    let(:fulfiller) { create( :current_registration, number_of_undergrads: 50,
      organization: create( :organization ) ).organization }
    let(:unfulfiller) { create( :current_registration,
      organization: create( :organization ) ).organization }

    def fulfill(f); f.current_registration.number_of_undergrads = 50; f.current_registration.save!; end
    def unfulfill(f); f.current_registration.number_of_undergrads = 0; f.current_registration.save!; end
    def fulfiller_to_membership(f); f.current_registration; end
    def fulfiller_to_reflection(f); f.current_registration.organization; end
    def build_membership; build :registered_membership; end
  end

  it_behaves_like 'notifiable' do
    let( :event ) { :registration_required }
  end

end

