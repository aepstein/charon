require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @valid_attributes = {
      :request_structure_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Request.create!(@valid_attributes)
  end
end
