require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    basis = Factory(:basis)
    basis.structure.nodes.create(Factory.attributes_for(:node))
    request = Factory(:request, :basis => basis)
    @item = request.items.build(:node => basis.structure.nodes.first)
  end

  it "should save with valid attributes" do
    @item.save.should == true
  end

  it "should have a next_stage method that returns the stage_id of the next version to be made" do
    version1 = Factory(:version)
    version2 = Factory(:version, :stage_id => 1)
    @item.versions.next_stage.should == 0
    @item.versions << version1
    @item.versions[0].stage.should == "request"
    @item.versions.next_stage.should == 1
    @item.versions << version2
    @item.versions[1].stage.should == "review"
    @item.versions.next_stage.should == 2
  end

  it "should have may_create? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_create?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_create?(nil).should == false
  end

  it "should have may_update? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_update?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_update?(nil).should == false
  end

  it "should have may_destroy? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_destroy?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_destroy?(nil).should == false
  end

  it "should have may_see? which returns same value as request.may_see?" do
    @item.request.stub!(:may_see?).and_return(true)
    @item.may_see?(nil).should == true
    @item.request.stub!(:may_see?).and_return(false)
    @item.may_see?(nil).should == false
  end
end

