require 'spec_helper'

describe Agreement do
  before(:each) do
    @agreement = build(:agreement)
  end

  it "should create a new instance given valid attributes" do
    @agreement.save!
  end

  it "should not save without a name" do
    @agreement.name = nil
    @agreement.save.should be_false
  end

  it "should not save with a duplicate name" do
    @agreement.save!
    duplicate = build(:agreement, :name => @agreement.name)
    duplicate.save.should be_false
  end

  it "should not save without content" do
    @agreement.content = nil
    @agreement.save.should be_false
  end

  it "should have authorization methods for approvable" do
    @agreement.approve.should eql true
    @agreement.unapprove.should eql true
  end

  it "should record fulfillment on approval" do
    @agreement.save!
    approval = create(:approval, :approvable => @agreement)
    @agreement.fulfillments.size.should eql 1
    @agreement.fulfillments.first.fulfiller.should eql approval.user
  end

  it "should have unapprove method the removes fulfillment" do
    @agreement.save!
    approval = create(:approval, :approvable => @agreement)
    approval.destroy
    approval.user.fulfillments.size.should eql 0
  end

  it 'should return a fulfiller_type of "User"' do
    Agreement.fulfiller_type.should eql 'User'
  end

  xit "should delete associated approvals if content is changed" do
    new_name = 'new name'
    new_content = 'new content'
    agreement = create(:agreement)
    agreement.name.should_not == new_name
    agreement.content.should_not == new_content
    agreement.approvals.create( :user => create(:user), :as_of => agreement.updated_at ).id.should_not be_nil
    agreement.approvals.size.should == 1
    agreement.name = new_name
    agreement.save.should == true
    agreement.approvals.size.should == 1
    agreement.content = new_content
    agreement.save.should == true
    agreement.approvals(true).should be_empty
  end
end

