require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration)
    @registered_organization.registrations.first.update_attributes(
      { :registered => true, :number_of_undergrads => 10 }
    )

    @pres_membership = Factory(:president_membership)
    @tre_membership = Factory(:treasurer_membership)
    @adv_membership = Factory(:advisor_membership)
    @other_membership = Factory(:membership)

    @registered_organization.memberships << @pres_membership
    @registered_organization.memberships << @tre_membership
    @registered_organization.memberships << @adv_membership
    @registered_organization.memberships << @other_membership

    @request = Factory.build(:request)
    @request.organizations << @registered_organization
  end

  it "should create a new instance given valid attributes" do
    @request.organizations.each do |organization|
      @request.organizations.allowed?(organization).should == true
    end
    @request.save.should == true
  end

  it "should not create a new instance after a basis has closed" do
    request = Factory.build(:request)
    request.basis.open_at = DateTime.now - 2.days
    request.basis.closed_at = DateTime.now - 1.days
    request.basis.save.should == true
    request.save.should == false
  end

  it "should not save without an organization" do
    @request.organizations.delete_all
    @request.save.should == false
  end

  it "should be able to be created only by finance officers of its organization(s)" do
    @request.may_create?(@pres_membership.user).should == true
    @request.may_create?(@tre_membership.user).should == true
    @request.may_create?(@adv_membership.user).should == true
    @request.may_create?(@other_membership.user).should == false
  end

  it "should be able to be updated by any member of its organization(s)" do
    @request.may_update?(@pres_membership.user).should == true
    @request.may_update?(@tre_membership.user).should == true
    @request.may_update?(@adv_membership.user).should == true
    @request.may_update?(@other_membership.user).should == true
  end

  it "should be viewable by any member of its organization(s)" do
    @request.may_see?(@pres_membership.user).should == true
    @request.may_see?(@tre_membership.user).should == true
    @request.may_see?(@adv_membership.user).should == true
    @request.may_see?(@other_membership.user).should == true
  end

  it "should be able to be approved only by finance officers of its organization(s)" do
    @request.may_approve?(@pres_membership.user).should == true
    @request.may_approve?(@tre_membership.user).should == true
    @request.may_approve?(@adv_membership.user).should == true
    @request.may_approve?(@other_membership.user).should == false
  end

end

