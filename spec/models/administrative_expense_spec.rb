require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdministrativeExpense do
  before(:each) do
    @valid_attributes = {
      :copies => 1,
      :copies_expense => 9.99,
      :repairs_restocking => 9.99,
      :mailbox_wsh => 1,
      :total_request => 9.99,
      :total => 9.99
    }
  end

  it "should create a new instance given valid attributes" do
    AdministrativeExpense.create!(@valid_attributes)
  end
end
