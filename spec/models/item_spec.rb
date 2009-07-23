require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })
    @pres_membership = Factory(:president_membership)
    @other_membership = Factory(:membership)
    @registered_organization.memberships << @pres_membership
    @registered_organization.memberships << @other_membership
    @request = Factory.build(:request)
    @request.organizations << @registered_organization
    @item = Factory(:item)
    @item.request = @request
  end

  it "should have a next_stage method that returns the stage_id of the next version to be made" do
    @version1 = Factory.build(:version)
    @version1.requestable = Factory(:administrative_expense)
    @version2 = Factory.build(:version, { :stage_id => 1 })
    @version2.requestable = Factory(:administrative_expense)
    @item.versions.next_stage.should == 0
    @item.versions << @version1
    @item.versions[0].stage.should == "request"
    @item.versions.next_stage.should == 1
    @item.versions << @version2
    @item.versions[1].stage.should == "review"
    @item.versions.next_stage.should == 2
  end

  it "should be able to be created by any user who can update its request" do
    @item.may_create?(@pres_membership.user).should == true
    @item.may_create?(@other_membership.user).should == true
  end

  it "should be able to be updated by any user who can update its request" do
    @item.may_update?(@pres_membership.user).should == true
    @item.may_update?(@other_membership.user).should == true
  end

  it "should be able to be destroyed by any user who can update its request" do
    @item.may_destroy?(@pres_membership.user).should == true
    @item.may_destroy?(@other_membership.user).should == true
  end

  it "should be viewable by any user who can see its request" do
    @item.may_see?(@pres_membership.user).should == true
    @item.may_see?(@other_membership.user).should == true
  end
end

