require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Basis do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    Factory(:basis).new_record?.should == false
  end

  it "should not save with a close date before the open date" do
    basis = Factory.build(:basis)
    basis.open_at = DateTime.now + 1.days
    basis.closed_at = DateTime.now - 1.days
    basis.save.should == false
  end

  it "should not save without a structure" do
    basis = Factory(:basis)
    basis.structure = nil
    basis.save.should == false
  end

end

