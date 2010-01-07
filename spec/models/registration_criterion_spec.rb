require 'spec_helper'

describe RegistrationCriterion do
  before(:each) do
    @criterion = Factory(:registration_criterion)
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

  it 'should not save without must_register specified' do
    @criterion.must_register = nil
    @criterion.save.should be_false
  end
end

