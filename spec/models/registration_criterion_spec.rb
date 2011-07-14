require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrationCriterion do
  before(:each) do
    @criterion = create(:registration_criterion)
  end

  it "should create a new instance given valid attributes" do
    @criterion.id.should_not be_nil
  end

  it 'should not save without a valid minimal_percentage' do
    @criterion.minimal_percentage = nil
    @criterion.save.should be_false
    @criterion.minimal_percentage = -1
    @criterion.save.should be_false
    @criterion.minimal_percentage = 101
    @criterion.save.should be_false
  end

  it 'should not save without a valid type_of_member' do
    @criterion.type_of_member = nil
    @criterion.save.should be_false
    @criterion.type_of_member = 'undergrad'
    Registration::MEMBER_TYPES.should_not include @criterion.type_of_member
    @criterion.save.should be_false
  end

  it 'should not save a duplicate' do
    duplicate = build(:registration_criterion)
    duplicate.minimal_percentage.should eql @criterion.minimal_percentage
    duplicate.type_of_member.should eql @criterion.type_of_member
    duplicate.must_register.should eql @criterion.must_register
    duplicate.save.should be_false
  end

  it 'should correctly fulfill organizations on create and update' do
    members_and_registration_ok = create(:current_registration, :organization => create(:organization), :number_of_others => 50, :registered => true )
    members_only_ok = create(:current_registration, :organization => create(:organization), :number_of_others => 50 )
    neither_ok = create(:current_registration, :organization => create(:organization), :number_of_undergrads => 50 )
    criterion = create(:registration_criterion, :minimal_percentage => 50, :type_of_member => 'others', :must_register => true)
    criterion.fulfillments.size.should eql 1
    criterion.fulfillments.first.fulfiller_id.should eql members_and_registration_ok.organization_id
    criterion.must_register = false
    criterion.save.should be_true
    criterion.fulfillments.size.should eql 2
    criterion.fulfillments.first.fulfiller_id.should eql members_and_registration_ok.organization_id
    criterion.fulfillments.last.fulfiller_id.should eql members_only_ok.organization_id
    criterion.type_of_member = 'undergrads'
    criterion.save.should be_true
    criterion.fulfillments.size.should eql 1
    criterion.fulfillments.first.fulfiller_id.should eql neither_ok.organization_id
  end

  it 'should return a fulfiller_type of "Organization"' do
    RegistrationCriterion.fulfiller_type.should eql 'Organization'
  end

end

