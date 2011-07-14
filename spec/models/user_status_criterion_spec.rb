require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserStatusCriterion do
  before(:each) do
    @criterion = create(:user_status_criterion)
  end

  it "should create a new instance given valid attributes" do
    @criterion.id.should_not be_nil
  end

  it 'should not save a duplicate criterion' do
    duplicate = build(:user_status_criterion)
    duplicate.statuses = @criterion.statuses
    duplicate.save.should be_false
  end

  it 'should not save without any statuses' do
    @criterion.statuses_mask = 0
    @criterion.save.should eql false
  end

  it 'should correctly fulfill users on create and update' do
    fulfilled = user_with_status 'grad'
    unfulfilled = user_with_status 'temporary'
    fulfilled.status.should_not eql unfulfilled.status
    criterion = create(:user_status_criterion, :statuses => [fulfilled.status])
    criterion.fulfillments.size.should eql 1
    criterion.fulfillments.first.fulfiller_id.should eql fulfilled.id
    criterion.statuses = [unfulfilled.status]
    criterion.save.should eql true
    criterion.fulfillments.size.should eql 1
    criterion.fulfillments.first.fulfiller_id.should eql unfulfilled.id
  end

  it 'should return a fulfiller_type of "User"' do
    UserStatusCriterion.fulfiller_type.should eql 'User'
  end

  def user_with_status(status)
    create(:user, :status => status)
  end
end

