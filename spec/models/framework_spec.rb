require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Framework do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :member_percentage => 1,
      :member_percentage_type => "value for member_percentage_type"
    }
  end

  it "should create a new instance given valid attributes" do
    Framework.create!(@valid_attributes)
  end
end
