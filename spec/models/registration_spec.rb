require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registration do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    create(:registration).new_record?.should == false
  end

  it "should calculate percent_members_of_type correctly" do
    factory = create(:registration)
    factory.number_of_undergrads = 60
    factory.percent_members_of_type(:undergrads).should == 100.0
  end

  it "should be able to create an organization from the registration" do
    registration = create(:registration)
    organization = registration.find_or_create_organization
    organization.id.should_not be_nil
    organization.registrations << registration
    registration.organization_id.should == organization.id
    registration.find_or_create_organization.should == organization
  end

  it 'should fulfill/unfulfill related organizations on create/update' do
    criterion1 = create(:registration_criterion, :minimal_percentage => 50,
      :type_of_member => 'undergrads', :must_register => true)
    criterion2 = create(:registration_criterion, :minimal_percentage => 50,
      :type_of_member => 'undergrads', :must_register => false)
    criterion3 = create(:registration_criterion, :minimal_percentage => 50,
      :type_of_member => 'others', :must_register => false)
    registration = create(:current_registration,
      :organization => create(:organization), :number_of_undergrads => 10,
      :registered => true )
    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
    fulfillables.size.should eql 2
    fulfillables.should include criterion1
    fulfillables.should include criterion2
    registration.registered = false
    registration.save!
    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
    fulfillables.length.should eql 1
    fulfillables.should include criterion2
    registration.number_of_others = 11
    registration.save!
    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
    fulfillables.length.should eql 1
    fulfillables.should include criterion3
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
    organization.memberships.reset
    organization.memberships.length.should eql 0
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

