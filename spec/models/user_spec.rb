require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @admin = Factory(:user, :admin => true)
    @regular = Factory(:user)
  end

  it "should save a valid user" do
    Factory(:user).id.should_not be_nil
  end

  it "should have a organizations method that returns organizations related by active memberships" do
    user = Factory(:user)
    active = user.memberships.create( :role => Factory(:role), :organization => Factory(:organization), :active => true )
    inactive = user.memberships.create( :role => Factory(:role), :organization => Factory(:organization), :active => false )
    user.organizations.size.should == 1
    user.organizations.should include(active.organization)
    user.organizations.should_not include(inactive.organization)
  end

  it "should have a may_create? which only allows admin" do
    owner = Factory.build(:user)
    owner.may_create?(@admin).should == true
    owner.may_create?(owner).should == false
    owner.may_create?(@regular).should == false
  end

  it "should have a may_see? which allows admin or owner" do
    owner = Factory(:user)
    owner.may_see?(@admin).should == true
    owner.may_see?(@regular).should == false
    owner.may_see?(owner).should == true
  end

  it "should have a may_update? which allows admin or owner" do
    owner = Factory(:user)
    owner.may_update?(@admin).should == true
    owner.may_update?(@regular).should == false
    owner.may_update?(owner).should == true
  end

  it "should have a may_destroy? which only allows admin" do
    owner = Factory(:user)
    owner.may_destroy?(@admin).should == true
    owner.may_destroy?(@regular).should == false
    owner.may_destroy?(owner).should == false
  end

  it 'should automatically fulfill user status criterions on create and update' do
    criterion = Factory(:user_status_criterion, :statuses => %w( staff faculty ) )
    criterion2 = Factory(:user_status_criterion, :statuses => %w( temporary ) )
    user = Factory(:user, :status => 'staff')
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql criterion
    user.status = 'temporary'
    user.save.should be_true
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql criterion2
  end

end

