require 'spec_helper'

describe RegistrationCriterion do

  let( :criterion ) { build( :registration_criterion ) }

  it "should create a new instance given valid attributes" do
    criterion.save!
  end

  it 'should not save without a valid minimal_percentage' do
    criterion.minimal_percentage = -1
    criterion.save.should be_false
    criterion.minimal_percentage = 101
    criterion.save.should be_false
  end

  it 'should not save without a valid type_of_member' do
    criterion.type_of_member = 'undergrad'
    Registration::MEMBER_TYPES.should_not include criterion.type_of_member
    criterion.save.should be_false
  end

  it 'should not save a duplicate' do
    criterion.save!
    duplicate = build(:registration_criterion)
    duplicate.minimal_percentage.should eql criterion.minimal_percentage
    duplicate.type_of_member.should eql criterion.type_of_member
    duplicate.must_register.should eql criterion.must_register
    duplicate.save.should be_false
  end

  context 'fulfiller scopes' do

    let (:conforming_registration) { create :registration, number_of_undergrads: 10, registered: true }
    let (:nonconforming_registration) { create :registration, number_of_undergrads: 0, registered: false }
    let (:permissive_criterion) { create :registration_criterion, must_register: false }

    before(:each) do
      conforming_registration
      nonconforming_registration
      permissive_criterion
    end

    it "should have minimal_percentage_fulfilled_by scope" do
      criterion.must_register = false
      criterion.type_of_member = 'undergrads'
      criterion.minimal_percentage = 50
      criterion.save!
      test_scope :minimal_percentage_fulfilled_by
    end

    it "should have must_register_fulfilled_by scope" do
      criterion.must_register = true
      criterion.type_of_member = nil
      criterion.minimal_percentage = nil
      criterion.save!
      test_scope :must_register_fulfilled_by
    end

    it "should have fulfilled_by_registration scope" do
      criterion.must_register = true
      criterion.type_of_member = 'undergrads'
      criterion.minimal_percentage = 50
      criterion.save!
      test_scope :fulfilled_by_registration
      nonconforming_registration.update_attribute :number_of_undergrads, 10
      test_scope :fulfilled_by_registration
      nonconforming_registration.update_attributes number_of_undergrads: 0, registered: true
      test_scope :fulfilled_by_registration
    end

    it "should have fulfilled_by scope that calls fulfilled_by_registration for registration" do
      organization = create :organization, registrations: [ create(:current_registration) ]
      RegistrationCriterion.should_receive(:fulfilled_by_registration).
        with organization.current_registration
      RegistrationCriterion.fulfilled_by organization
    end

    it "should have a fulfilled_by scope that raises ArgumentError on non-registration" do
      expect { RegistrationCriterion.fulfilled_by criterion }.
        to raise_error ArgumentError, "received RegistrationCriterion instead of Organization"
    end

    def test_scope(scope)
      result = RegistrationCriterion.scoped.send(scope, conforming_registration)
      result.length.should eql 2
      result = RegistrationCriterion.scoped.send(scope, nonconforming_registration)
      result.length.should eql 1
      result.should include permissive_criterion
    end
  end

# TODO implement in shared example groups
#  it 'should correctly fulfill organizations on create and update' do
#    members_and_registration_ok = create(:current_registration, :organization => create(:organization), :number_of_others => 50, :registered => true )
#    members_only_ok = create(:current_registration, :organization => create(:organization), :number_of_others => 50 )
#    neither_ok = create(:current_registration, :organization => create(:organization), :number_of_undergrads => 50 )
#    criterion = create(:registration_criterion, :minimal_percentage => 50, :type_of_member => 'others', :must_register => true)
#    criterion.fulfillments.size.should eql 1
#    criterion.fulfillments.first.fulfiller_id.should eql members_and_registration_ok.organization_id
#    criterion.must_register = false
#    criterion.save.should be_true
#    criterion.fulfillments.size.should eql 2
#    criterion.fulfillments.first.fulfiller_id.should eql members_and_registration_ok.organization_id
#    criterion.fulfillments.last.fulfiller_id.should eql members_only_ok.organization_id
#    criterion.type_of_member = 'undergrads'
#    criterion.save.should be_true
#    criterion.fulfillments.size.should eql 1
#    criterion.fulfillments.first.fulfiller_id.should eql neither_ok.organization_id
#  end

# TODO: part of fulfillable shared example group
#  it 'should return a fulfiller_type of "Organization"' do
#    RegistrationCriterion.fulfiller_type.should eql 'Organization'
#  end

end

