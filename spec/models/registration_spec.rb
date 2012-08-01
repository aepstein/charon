require 'spec_helper'

describe Registration do

  let(:registration) { build(:registration) }
  let(:current_registration) { build(:current_registration) }

  context 'validation' do
    it "should create a new instance given valid attributes" do
      registration.save!
    end

    it "should not save without a registration_term" do
      registration.registration_term = nil
      registration.save.should be_false
    end
  end

  context "member composition accessors" do
    it "should have number_of_members return 0 if no members" do
      registration.number_of_members.should eql 0
    end

    it "should have number_of_members return 2 if 2 members" do
      registration.number_of_undergrads = 1
      registration.number_of_grads = 1
      registration.number_of_members.should eql 2
    end

    it "should have number_of_members? return false if no members" do
      registration.number_of_members?.should be_false
    end

    it "should have number_of_members? return true if members" do
      registration.number_of_undergrads = 1
      registration.number_of_members?.should be_true
    end

    it "should have empty member_types if no members" do
      registration.member_types.should be_empty
    end

    it "should include non-zero member types if set" do
      registration.number_of_undergrads = 0
      registration.number_of_grads = 1
      registration.number_of_others = 2
      registration.member_types.length.should eql 2
      registration.member_types.should include 'grads', 'others'
    end

    it "should have number_of_members_changed? return false if no members changed" do
      registration.number_of_members_changed?.should be_false
    end

    it "should have number_of_members_changed? return true if members changed" do
      registration.number_of_undergrads = 1
      registration.number_of_members_changed?.should be_true
    end

    it "should return zero percent_members_of_type if no members" do
      registration.percent_members_of_type( 'undergrads' ).should eql 0.0
      registration.number_of_undergrads = 0
      registration.percent_members_of_type( 'undergrads' ).should eql 0.0
      registration.number_of_undergrads = nil
      registration.number_of_grads = 1
      registration.percent_members_of_type( 'undergrads' ).should eql 0.0
    end

    it "should return non-zero percent_members_of_type if members" do
      registration.number_of_undergrads = 1
      registration.number_of_grads = 1
      registration.percent_members_of_type( 'undergrads' ).should eql 50.0
    end

    it "should raise ArgumentError if invalid argument provided to percent_members_of_type" do
      expect { registration.percent_members_of_type 'undergrad' }.
        to raise_error ArgumentError, "undergrad is not a valid member type"
    end
  end

  context "organization matching" do

    it "should be able to create an organization from the registration" do
      registration = create(:registration)
      organization = registration.find_or_create_organization
      organization.id.should_not be_nil
      organization.registrations << registration
      registration.organization_id.should eql organization.id
      registration.find_or_create_organization.should eql organization
    end

    it 'should adopt an organization if that organization is matched to the same external_id' do
      organization = create(:registered_organization)
      organization.registrations.first.external_id.should_not be_nil
      registration = create(:registration, :external_id => organization.registrations.first.external_id)
      registration.organization.should eql organization
    end

    it 'should adopt a registration_term whose external_id matches its external_term_id' do
      term = create(:registration_term)
      term.external_id.should_not be_nil
      registration = create(:registration, :external_term_id => term.external_id)
      registration.registration_term.should eql term
    end

    it 'should have a peers scope that returns other registrations with same external_id' do
      registration = create(:registration)
      registration.external_id.should_not be_nil
      peer = create(:registration, :external_id => registration.external_id)
      other = create(:registration)
      other.external_id.should_not be_nil
      nonpeer = create(:registration, :external_id => nil)
      nonpeer.external_id.should be_nil
      nonsaved = build(:registration, :external_id => registration.external_id)
      nonsaved.external_id.should eql registration.external_id
      registration.peers.length.should eql 1
      registration.peers.should include peer
      other.peers.should be_empty
      nonpeer.peers.should be_empty
      nonsaved.peers.should be_empty
    end

    it 'should update peer registrations to point to the new organization if ' +
      'they are matched to the same external id' do
      # Mismatched record
      registration_matching_scenario create( :registration, :organization => create(:organization) )
      # Unmatched record
      registration_matching_scenario create( :registration, :organization => nil )
    end

    it 'should match unmatched or mismatched user records to the organization' do
      membership = create( :registered_membership )
      registration = membership.registration
      organization = create( :organization )
      organization.registrations << registration
      organization.memberships.length.should eql 1
      organization.memberships.should include membership
      other = create(:organization)
      other.registrations << registration
      other.memberships.length.should eql 1
      other.memberships.should include membership
      organization.association(:memberships).reset
      organization.memberships.length.should eql 0
    end

    it 'should set last_current_registration for an organization if registration is current' do
      organization = create( :organization )
      registration = create( :registration )
      registration.current?.should be_false
      organization.registrations << registration
      organization.last_current_registration.should be_nil
      current_registration = create( :current_registration )
      organization.registrations << current_registration
      organization.reload
      organization.last_current_registration.should eql current_registration
    end

    def registration_matching_scenario( registration )
      new_registration = create( :registration, :external_id => registration.external_id,
        :organization => create(:organization) )
      new_registration.external_id.should_not be_nil
      new_registration.external_id.should eql registration.external_id
      new_registration.organization.should_not be_nil
      new_registration.peers.should include registration
      registration = Registration.find registration.id
      registration.organization.should eql new_registration.organization
    end

  end

  context "registration criterions scope" do

    let( :registration ) { create :registration }
    let( :conforming_registration ) { create :registration, number_of_undergrads: 10,
      number_of_grads: 10,
      registered: true }

    before(:each) { registration; conforming_registration }

    it "should have fulfill_registration_criterions scope that selects for must_register condition" do
      criterion = create( :registration_criterion, must_register: true )
      test_scope_unfulfilled criterion
      registration.update_column :registered, true
      test_scope_fulfilled criterion
    end

    it "should have fulfill_registration_criterions scope that selects for member composition" do
      criterion = create( :registration_criterion, minimal_percentage: 50,
        type_of_member: 'undergrads', must_register: false )
      test_scope_unfulfilled criterion
      registration.update_attributes number_of_undergrads: 5, number_of_grads: 10
      test_scope_unfulfilled criterion
      registration.update_attributes number_of_grads: 0
      test_scope_fulfilled criterion
    end

    it "should have fulfill_registration_criterions scope that selects for combined condition" do
      criterion = create( :registration_criterion, minimal_percentage: 50,
        type_of_member: 'undergrads', must_register: true )
      test_scope_unfulfilled criterion
      registration.update_column :registered, true
      test_scope_unfulfilled criterion
      registration.update_attributes registered: false, number_of_undergrads: 10
      test_scope_unfulfilled criterion
      registration.update_column :registered, true
      test_scope_fulfilled criterion
    end

    def test_scope_unfulfilled(criterion)
      result = Registration.fulfill_registration_criterion criterion
      result.length.should eql 1
      result.should include conforming_registration
    end

    def test_scope_fulfilled(criterion)
      result = Registration.fulfill_registration_criterion criterion
      result.length.should eql 2
      result.should include registration, conforming_registration
    end

  end

end

