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

  it "should have a roles scope that returns agreements required for permissions of certain roles" do
    required_agreement = Factory(:agreement)
    unrequired_agreement = Factory(:agreement)
    irrelevant_agreement = Factory(:agreement)
    relevant_permission = Factory(:permission)
    relevant_permission.agreements << required_agreement
    irrelevant_permission = Factory(:permission)
    irrelevant_permission.role = Factory(:role)
    irrelevant_permission.save.should == true
    irrelevant_permission.agreements << irrelevant_agreement
    required_agreements = Agreement.roles(relevant_permission.role)
    required_agreements.should include(required_agreement)
    required_agreements.should_not include(unrequired_agreement)
    required_agreements.should_not include(irrelevant_agreement)
    required_agreements.size.should == 1
    required_agreements = Agreement.roles([relevant_permission.role,irrelevant_permission.role])
    required_agreements.should include(required_agreement)
    required_agreements.should_not include(unrequired_agreement)
    required_agreements.should include(irrelevant_agreement)
    required_agreements.size.should == 2
  end
end

