require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Structure do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:structure).id.should_not be_nil
  end

  it "should not save with an unallowed kind" do
    structure = Factory(:structure)
    structure.kind = structure.kind + 'blah'
    Structure::KINDS.should_not include(structure.kind)
    structure.save.should == false
  end

  it "should not save if maximum_requestors is less than minimum_requestors" do
    structure = Factory(:structure)
    structure.minimum_requestors = 2
    structure.maximum_requestors = 1
    structure.save.should == false
  end
end

