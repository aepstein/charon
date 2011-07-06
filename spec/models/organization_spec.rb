require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  before(:each) do
    @organization = Factory(:organization)
    @registered_organization = Factory(:registered_organization)
  end

  it "should create a new instance given valid attributes" do
    Factory(:organization).new_record?.should == false
  end

  it 'should not save without a last_name' do
    @organization.last_name = nil
    @organization.save.should be_false
  end

  it "should have a fund_requests.creatable method that returns fund_requests that can be made" do
    fund_source = Factory(:fund_source)
    started_fund_request = Factory(:fund_request, :organization => @organization)
    closed_fund_source = Factory(:fund_source, :open_at => DateTime.now - 1.year, :closed_at => DateTime.now - 1.day)
    fund_requests = @organization.fund_requests.creatable
    fund_requests.length.should == 1
    fund_requests.first.class.should == FundRequest
    fund_requests.first.fund_source.should eql fund_source
  end

  it "should reformat last_name of organizations such that An|A|The|Cornell are moved to first_name" do
    organization = Factory(:organization)
    parameters = {
      "A Club" => { :first => "A", :last => "Club" },
      "An Club" => { :first => "An", :last => "Club" },
      "The Club" => { :first => "The", :last => "Club" },
      "Cornell Club" => { :first => "Cornell", :last => "Club" },
      "The Cornell Club" => { :first => "The Cornell", :last => "Club" },
      "club" => { :first => "", :last => "club" }
    }
    parameters.each do |last_name, results|
      organization.last_name = last_name
      organization.save.should == true
      organization.first_name.should == results[:first]
      organization.last_name.should == results[:last]
      organization.first_name = "" && organization.last_name == ""
    end
  end

  it "should have a registered? method that checks whether the current registration is approved" do
    @registered_organization.registrations.first.current?.should be_true
    @registered_organization.registrations.first.registered?.should be_true
    @registered_organization.registrations.count.should eql 1
    Registration.active.count.should eql 1
    @registered_organization.registrations.current.should_not be_nil
    @registered_organization.registered?.should be_true
    Factory(:organization).registered?.should be_false
  end

end

