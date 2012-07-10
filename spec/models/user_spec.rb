require 'spec_helper'
require 'shared_examples/fulfiller_examples'

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

  context 'fulfiller' do
    let(:fulfillable_types) { %w( UserStatusCriterion Agreement ) }
    include_examples 'fulfiller module'
  end

  context 'user_status_criterion fulfiller' do
    include_examples 'fulfiller update_frameworks'

    let(:framework) { create :framework,
      requirements: [ build( :requirement,
        fulfillable: create( :user_status_criterion, statuses: %w( undergrad )
    ) ) ] }
    let(:fulfiller) { create :user, status: 'undergrad' }
    let(:unfulfiller) { create :user, status: 'temporary' }

    def fulfill(f); f.status = 'undergrad'; f.save!; end
    def unfulfill(f); f.status = 'temporary'; f.save!; end
  end

  context 'agreement fulfiller' do
    include_examples 'fulfiller update_frameworks'

    let(:fulfillable) { create :agreement }
    let(:framework) { create :framework,
      requirements: [ build( :requirement,
        fulfillable: fulfillable ) ] }
    let(:fulfiller) { create( :approval, approvable: fulfillable ).user }
    let(:unfulfiller) { create :user }

    def fulfill(f)
      create( :approval, approvable: fulfillable, user: f )
    end
    def unfulfill(f); f.approvals.clear; end
  end

end

