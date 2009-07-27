require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration, { :registered => true, :number_of_undergrads => 10 })

    @pres_membership = Factory(:president_membership)
    @tre_membership = Factory(:treasurer_membership)
    @adv_membership = Factory(:advisor_membership)
    @vp_membership = Factory(:vp_membership)
    @other_membership = Factory(:membership)
    @memberships = [@pres_membership, @tre_membership, @adv_membership, @vp_membership, @other_membership]
  end

  it "should have an officer_in? method that tells whether the user is an officer in an organization" do
    #@memberships.map { |m| m.user.officer_in?(@registered_organization) }.should == [false, false, false, false, false]
    @registered_organization.memberships << @memberships
    @memberships.map { |m| m.user.officer_in?(@registered_organization) }.should == [true, true, true, true, false]
  end

  it "should have a finance_officer_in? method that tells whether the user has certain positions in an organization" do
    #@memberships.map { |m| m.user.finance_officer_in?(@registered_organization) }.should == [false, false, false, false, false]
    @registered_organization.memberships << @memberships
    @memberships.map { |m| m.user.finance_officer_in?(@registered_organization) }.should == [true, true, true, false, false]
  end
end

