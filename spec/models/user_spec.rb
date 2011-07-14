require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @admin = create(:user, :admin => true)
    @regular = create(:user)
  end

  it "should save a valid user" do
    create(:user).id.should_not be_nil
  end

  it "should have a organizations method that returns organizations related by active memberships" do
    user = create(:user)
    active = user.memberships.build( :role_id => create(:role).id, :active => true )
    active.organization = create(:organization)
    active.save!
    inactive = user.memberships.create( :role_id => create(:role).id, :active => false )
    inactive.organization = create(:organization)
    inactive.save!
    user.organizations.size.should eql 1
    user.organizations.should include(active.organization)
    user.organizations.should_not include(inactive.organization)
  end

  it 'should automatically fulfill user status criterions on create and update' do
    criterion = create(:user_status_criterion, :statuses => %w( staff faculty ) )
    criterion2 = create(:user_status_criterion, :statuses => %w( temporary ) )
    user = create(:user, :status => 'staff')
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql criterion
    user.status = 'temporary'
    user.save.should be_true
    user.fulfillments.size.should eql 1
    user.fulfillments.first.fulfillable.should eql criterion2
  end

end

