require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Version do
  before(:each) do
    @version = Version.new(:item => Item.new)
  end

  it "should have may_create? which is true if request.may_allocate? and in review stage" do
    @version.request.stub!(:may_allocate?).and_return(true)
    @version.stage_id = 1
    @version.may_create?(nil).should == true
    @version.stage_id = 0
    @version.may_create?(nil).should == false
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.may_create?(nil).should == false
  end

  it "should have may_update? which is true if request.may_update? and in request stage or
  if request.may_allocate? and in review stage" do
    @version.request.stub!(:may_allocate?).and_return(true)
    @version.stage_id = 1
    @version.may_create?(nil).should == true
    @version.stage_id = 0
    @version.may_create?(nil).should == false
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.may_create?(nil).should == false
  end

  it "should have may_destroy? which is true if request.may_allocate? and in review stage" do
    @version.request.stub!(:may_allocate?).and_return(true)
    @version.stage_id = 1
    @version.may_create?(nil).should == true
    @version.stage_id = 0
    @version.may_create?(nil).should == false
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.may_create?(nil).should == false
  end

  it "should have may_see? which is true if request.may_allocate? and in review stage" do
    @version.request.stub!(:may_allocate?).and_return(true)
    @version.stage_id = 1
    @version.may_create?(nil).should == true
    @version.stage_id = 0
    @version.may_create?(nil).should == false
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.may_create?(nil).should == false
  end

end

