require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemberSource do
  before(:each) do
    @valid_attributes = {
      :organization_id => 1,
      :role_id => 1,
      :external_committee_id => 1,
      :minimum_votes => 1
    }
  end

  it "should create a new instance given valid attributes" do
    MemberSource.create!(@valid_attributes)
  end
end

