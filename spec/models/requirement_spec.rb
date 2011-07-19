require 'spec_helper'

describe Requirement do

  before(:each) do
    @requirement = build(:requirement)
  end

  context 'validations' do
    it "should create a new instance given valid attributes" do
      @requirement.save!
    end

    it 'should not save without a framework' do
      @requirement.framework = nil
      @requirement.save.should be_false
    end

    it 'should not save without a fulfillable' do
      @requirement.fulfillable = nil
      @requirement.save.should be_false
    end

    it 'should not save a duplicate' do
      @requirement.save!
      duplicate = build(:requirement)
      duplicate.framework = @requirement.framework
      duplicate.fulfillable = @requirement.fulfillable
      duplicate.save.should be_false
    end

    it 'should not save a fulfillable that is not of a valid type' do
      @requirement.fulfillable = create(:user)
      Fulfillment::FULFILLABLE_TYPES.values.flatten.
        should_not include @requirement.fulfillable_type
      @requirement.save.should be_false
    end
  end

  context 'scopes' do
    before(:each) do
      @requirement.save!
    end

    it 'should have a with_inner_fulfillments scope' do
      Requirement.with_inner_fulfillments.length.should eql 0
      create( :fulfillment, :fulfillable => @requirement.fulfillable )
      Requirement.with_inner_fulfillments.length.should eql 1
    end

    it 'should have a with_outer_fulfillments scope' do
      Requirement.with_outer_fulfillments.length.should eql 1
      create( :fulfillment, :fulfillable => @requirement.fulfillable )
      Requirement.with_outer_fulfillments.length.should eql 1
    end

    it 'should have fulfilled scope and unfulfilled scope' do
      fulfilled_fulfiller = create( :fulfillment,
        :fulfillable => @requirement.fulfillable ).fulfiller
      unfulfilled_fulfiller = create( :user )
      scope = Requirement.with_outer_fulfillments.fulfilled.
        group('requirements.id')
      scope.length.should eql 1
      scope.with_fulfillers( fulfilled_fulfiller ).length.should eql 1
      scope.with_fulfillers( unfulfilled_fulfiller ).length.should eql 0
      scope.with_fulfillers( fulfilled_fulfiller, unfulfilled_fulfiller ).
        length.should eql 1
      scope = Requirement.with_outer_fulfillments.unfulfilled.
        group('requirements.id')
      scope.length.should eql 0
      scope.with_fulfillers( fulfilled_fulfiller ).length.should eql 0
      scope.with_fulfillers( unfulfilled_fulfiller ).length.should eql 1
      scope.with_fulfillers( fulfilled_fulfiller, unfulfilled_fulfiller ).
        length.should eql 0
    end
  end
end

