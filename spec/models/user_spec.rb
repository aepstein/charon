require 'spec_helper'

describe User do

  let( :user ) { build :user }

  it "should save a valid user" do
    user.save!
  end

  it "should have a organizations method that returns organizations related by active memberships" do
    user.save!
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

  context 'fulfillments' do

    let(:user) { create :user, status: 'undergrad' }
    let(:fulfilled_user_status_criterion) { create :user_status_criterion, statuses: [ user.status ] }
    let(:unfulfilled_user_status_criterion) { create :user_status_criterion, statuses: %w( grad ) }
    let(:fulfilled_agreement) { create( :approval, user: user,
      approvable: create( :agreement ) ).approvable }
    let(:unfulfilled_agreement) { create :agreement }

    it "should have a fulfill_user_status_criterion scope" do
      test_scope :fulfill_user_status_criterion,
        fulfilled_user_status_criterion, unfulfilled_user_status_criterion
    end

    it "should have a fulfill_agreement scope" do
      test_scope :fulfill_agreement,
        fulfilled_agreement, unfulfilled_agreement
    end

    def test_scope(scope, fulfilled_criterion, unfulfilled_criterion)
      result = User.send(scope, fulfilled_criterion)
      result.length.should eql 1
      result.should include user
      result = User.send(scope, unfulfilled_criterion)
      result.length.should eql 0
    end

  end

#  it 'should automatically fulfill user status criterions on create and update' do
#    criterion = create(:user_status_criterion, :statuses => %w( staff faculty ) )
#    criterion2 = create(:user_status_criterion, :statuses => %w( temporary ) )
#    user = create(:user, :status => 'staff')
#    user.fulfillments.size.should eql 1
#    user.fulfillments.first.fulfillable.should eql criterion
#    user.status = 'temporary'
#    user.save.should be_true
#    user.fulfillments.size.should eql 1
#    user.fulfillments.first.fulfillable.should eql criterion2
#  end

end

