require 'spec_helper'

describe Framework do

  before(:each) do
    @framework = build(:framework)
  end

  context 'validations' do
    it "should create a new instance given valid attributes" do
      @framework.save!
    end

    it "should not save without a name" do
      @framework.name = ""
      @framework.save.should be_false
    end

    it "should not save with a name that is not unique" do
      @framework.save!
      second_framework = build(:framework,:name => @framework.name)
      second_framework.save.should be_false
    end
  end

  context 'scopes' do
    before(:each) do
      @framework.save!
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

    it 'should have fulfilled_for/unfulfilled_for subject check only global requirements' do
      scope_fulfilled_for(@user).length.should eql 0
      scope_fulfilled_for(@organization).length.should eql 0
      scope_unfulfilled_for(@user).length.should eql 1
      scope_unfulfilled_for(@organization).length.should eql 1
      create( :fulfillment, :fulfillable => @user_global.fulfillable, :fulfiller => @user )
      scope_fulfilled_for(@user).length.should eql 1
      scope_fulfilled_for(@organization).length.should eql 0
      scope_unfulfilled_for(@user).length.should eql 0
      scope_unfulfilled_for(@organization).length.should eql 1
      create( :fulfillment, :fulfillable => @organization_global.fulfillable,
        :fulfiller => @organization )
      scope_fulfilled_for(@user).length.should eql 1
      scope_fulfilled_for(@organization).length.should eql 1
      scope_unfulfilled_for(@user).length.should eql 0
      scope_unfulfilled_for(@organization).length.should eql 0
    end

    it 'should have fulfilled_for/unfulfilled_for subjects check global and role-specific' do
      scope_fulfilled_for( [@organization,@user] ).length.should eql 0
      scope_unfulfilled_for( [@organization,@user] ).length.should eql 1
      create( :fulfillment, :fulfillable => @user_global.fulfillable,
        :fulfiller => @user )
      scope_fulfilled_for( [@organization,@user] ).length.should eql 0
      scope_unfulfilled_for( [@organization,@user] ).length.should eql 1
      create( :fulfillment, :fulfillable => @organization_global.fulfillable,
        :fulfiller => @organization )
      scope_fulfilled_for( [@organization,@user] ).length.should eql 0
      scope_unfulfilled_for( [@organization,@user] ).length.should eql 1
      create( :fulfillment, :fulfillable => @user_role.fulfillable,
        :fulfiller => @user )
      scope_fulfilled_for( [@organization,@user] ).length.should eql 1
      scope_unfulfilled_for( [@organization,@user] ).length.should eql 0
    end

    def scope_fulfilled_for(subjects, perspective=nil)
      perspective ||= FundEdition::PERSPECTIVES.first
      Framework.fulfilled_for( perspective, subjects )
    end

    def scope_unfulfilled_for(subjects, perspective=nil)
      perspective ||= FundEdition::PERSPECTIVES.first
      Framework.unfulfilled_for( perspective, subjects )
    end

  end
end

