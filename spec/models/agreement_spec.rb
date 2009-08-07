require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Agreement do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory(:agreement).id.should_not be_nil
  end

  it "should not save without a name" do
    agreement = Factory(:agreement)
    agreement.name = nil
    agreement.save.should == false
  end

  it "should not save with a duplicate name" do
    agreement = Factory(:agreement)
    duplicate = agreement.clone
    duplicate.save.should == false
  end

  it "should not save without content" do
    agreement = Factory(:agreement)
    agreement.content = nil
    agreement.save.should == false
  end

  it "should have methods for approvable" do
    agreement = Factory(:agreement)
    agreement.may_approve?(nil).should == true
    agreement.may_unapprove?(nil).should == false
    agreement.may_unapprove_other?(nil).should == false
    agreement.approve!.should be_nil
    agreement.unapprove!.should be_nil
  end

  it "should include the GlobalModelAuthorization module" do
    Agreement.included_modules.should include(GlobalModelAuthorization)
  end
end

