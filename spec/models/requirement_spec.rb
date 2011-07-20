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
      @framework = create(:framework)
      @organization = create(:organization)
      role = create(:requestor_role)
      membership = create(:membership, :organization => @organization,
        :role => role)
      @user = membership.user
      @user_global = create( :requestor_requirement, :framework => @framework )
      @user_role = create( :requestor_requirement, :framework => @framework,
        :role => membership.role )
      @organization_global = create( :requestor_requirement, :framework => @framework,
        :fulfillable => create( :registration_criterion ) )
    end

    it 'should have a with_inner_fulfillments scope' do
      Requirement.with_inner_fulfillments.length.should eql 0
      create( :fulfillment, :fulfillable => @requirement.fulfillable )
      Requirement.with_inner_fulfillments.length.should eql 1
    end

    it 'should have a with_outer_fulfillments scope' do
      Requirement.with_outer_fulfillments.length.should eql 4
      create( :fulfillment, :fulfillable => @requirement.fulfillable )
      Requirement.with_outer_fulfillments.length.should eql 4
    end

    it 'should have for_perspective_and_subjects invoke _subject with 2 arguments' do
      Requirement.should_receive :for_subject
      Requirement.for_perspective_and_subjects(
        FundEdition::PERSPECTIVES.first, @user )
    end

    it 'should have for_perspective_and_subjects invoke _subjects with 3 arguments' do
      Requirement.should_receive :for_subjects
      Requirement.for_perspective_and_subjects( FundEdition::PERSPECTIVES.first,
        @user, @organization )
    end

    it 'should have for_perspective_and_subjects invoke _subjects with array second argument' do
      Requirement.should_receive :for_subjects
      Requirement.for_perspective_and_subjects( FundEdition::PERSPECTIVES.first,
        [ @user, @organization ] )
    end

    it 'should have for_perspective which limits to a perspective' do
      Requirement.for_perspective('requestor').count.should eql 3
    end

    it 'should have a for_subject which limits to global roles for a subject' do
      scope = Requirement.for_subject( @user )
      scope.length.should eql 2
      scope.should include @requirement, @user_global
      scope = Requirement.for_subject( @organization )
      scope.length.should eql 1
      scope.should include @organization_global
    end

    it 'should have a for_subjects which includes global and o/u role locals' do
      other_role = create( :role, :name => Role::REQUESTOR[1] )
      other_role.should_not eql @role
      create( :membership, :organization => @organization, :active => true,
        :role => other_role )
      create( :requestor_requirement, :role => other_role )
      scope = Requirement.where( :framework_id => @framework.id ).
        for_subjects( 'requestor', @organization, @user )
      scope.length.should eql 3
      scope.should include @user_global, @organization_global, @user_role
    end

    it 'should have fulfilled scope and unfulfilled scope' do
      fulfilled_fulfiller = create( :fulfillment,
        :fulfillable => @requirement.fulfillable ).fulfiller
      unfulfilled_fulfiller = create( :user )
      scope = Requirement.where( :framework_id => @requirement.framework_id ).
        with_outer_fulfillments.fulfilled.group('requirements.id')
      scope.length.should eql 1
      scope.with_fulfillers( fulfilled_fulfiller ).length.should eql 1
      scope.with_fulfillers( unfulfilled_fulfiller ).length.should eql 0
      scope.with_fulfillers( fulfilled_fulfiller, unfulfilled_fulfiller ).
        length.should eql 1
      scope = Requirement.where( :framework_id => @requirement.framework_id ).
        with_outer_fulfillments.unfulfilled.group('requirements.id')
      scope.length.should eql 0
      scope.with_fulfillers( fulfilled_fulfiller ).length.should eql 0
      scope.with_fulfillers( unfulfilled_fulfiller ).length.should eql 1
      scope.with_fulfillers( fulfilled_fulfiller, unfulfilled_fulfiller ).
        length.should eql 0
    end
  end
end

