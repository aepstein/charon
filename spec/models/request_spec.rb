require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @registered_organization = Factory(:organization)
    @registered_organization.registrations << Factory(:registration)
    @registered_organization.registrations.first.update_attributes(
      { :registered => true, :number_of_undergrads => 10 }
    )
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
end

