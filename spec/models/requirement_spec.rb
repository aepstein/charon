require 'spec_helper'

describe Requirement do

  let( :requirement ) { build :requirement }

  context 'validations' do
    it "should create a new instance given valid attributes" do
      requirement.save!
    end

    it 'should not save without a framework' do
      requirement.framework = nil
      requirement.save.should be_false
    end

    it 'should not save without a fulfillable' do
      requirement.fulfillable = nil
      requirement.save.should be_false
    end

    it 'should not save a duplicate' do
      requirement.save!
      duplicate = build(:requirement)
      duplicate.framework = requirement.framework
      duplicate.fulfillable = requirement.fulfillable
      duplicate.save.should be_false
    end

    it 'should not save a fulfillable that is not of a valid type' do
      requirement.fulfillable = create(:user)
      Requirement::FULFILLABLE_TYPES.values.flatten.
        should_not include requirement.fulfillable_type
      requirement.save.should be_false
    end
  end

end

