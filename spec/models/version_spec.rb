require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Version do
  before(:each) do
    @version = Factory(:version)
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
    @version.stage_id = 0
    @version.request.stub!(:may_update?).and_return(true)
    @version.may_update?(nil).should == true
    @version.request.stub!(:may_update?).and_return(false)
    @version.may_update?(nil).should == false
    @version.stage_id = 1
    @version.request.stub!(:may_allocate?).and_return(true)
    @version.may_update?(nil).should == true
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.may_update?(nil).should == false
  end

  it "should have may_destroy? which is false" do
    @version.stage_id = 0
    @version.may_destroy?(nil).should == false
    @version.stage_id = 1
    @version.may_destroy?(nil).should == false
  end

  it "should have may_see? which is true if request.may_see? and in request stage or
  if (request.may_allocate? or request.may_review?) and in review stage" do
    @version.stage_id = 0
    @version.request.stub!(:may_see?).and_return(true)
    @version.may_see?(nil).should == true
    @version.request.stub!(:may_see?).and_return(false)
    @version.may_see?(nil).should == false
    @version.stage_id = 1
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.request.stub!(:may_review?).and_return(false)
    @version.may_see?(nil).should == false
    @version.request.stub!(:may_allocate?).and_return(true)
    @version.may_see?(nil).should == true
    @version.request.stub!(:may_review?).and_return(true)
    @version.may_see?(nil).should == true
    @version.request.stub!(:may_allocate?).and_return(false)
    @version.may_see?(nil).should == true
  end

end

