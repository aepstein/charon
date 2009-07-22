require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Version do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })
    @pres_membership = Factory(:president_membership)
    @other_membership = Factory(:membership)
    @registered_organization.memberships << @pres_membership
    @registered_organization.memberships << @other_membership
    @request = Factory.build(:request)
    @request.organizations << @registered_organization
    @request.stub!(:may_allocate?).and_return(true)
    @item = Factory(:item)
    @item.request = @request
    @version1 = Factory.build(:version)
    @version1.requestable = Factory(:administrative_expense)
    @version1.item = @item
    @version2 = Factory.build(:version, { :stage_id => 1 })
    @version2.requestable = Factory(:administrative_expense)
    @version2.item = @item
  end

  it "should work with stubs" do
    @version1.item.request.may_allocate?.should == true
    @version2.item.request.may_allocate?(@pres_membership.user).should == true
  end

end

