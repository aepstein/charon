require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })
    @pres_membership = Factory(:president_membership)
    @other_membership = Factory(:membership)
    @registered_organization.memberships << @pres_membership
    @registered_organization.memberships << @other_membership
    @request = Factory(:request)
    @request.organizations << @registered_organization
    @item = Factory(:item, { :request => @request })
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

  it "should have may_create? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_create?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_create?(nil).should == false
  end

  it "should have may_update? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_update?(@pres_membership.user).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_update?(@other_membership.user).should == false
  end

  it "should have may_destroy? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_destroy?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_destroy?(nil).should == false
  end

  it "should have may_see? which returns same value as request.may_see?" do
    @item.request.stub!(:may_see?).and_return(true)
    @item.may_see?(nil).should == true
    @item.request.stub!(:may_see?).and_return(false)
    @item.may_see?(nil).should == false
  end
end

