require 'spec_helper'
require 'shared_examples/fulfillable_examples'

describe UserStatusCriterion do

  let( :criterion ) { build :user_status_criterion }

  it "should create a new instance given valid attributes" do
    criterion.save!
  end

  it 'should not save a duplicate criterion' do
    criterion.save!
    duplicate = build(:user_status_criterion)
    duplicate.statuses = criterion.statuses
    duplicate.save.should be_false
  end

  it 'should not save without any statuses' do
    criterion.statuses_mask = 0
    criterion.save.should be_false
  end

  context 'fulfillment scopes' do

    let( :conforming_user ) { create( :user, status: 'undergrad' ) }
    let( :nonconforming_user ) { create( :user, status: 'grad' ) }
    let( :permissive_criterion ) { create( :user_status_criterion, statuses: User::STATUSES ) }

    before(:each) do
      conforming_user
      nonconforming_user
      permissive_criterion
    end

    it "should have with_status scope" do
      criterion.save!
      test_scope :with_status
    end

    it "should return no criteria for blank status" do
      UserStatusCriterion.with_status(nil).length.should eql 0
    end

    it "should have fulfilled_by scope which calls with_status" do
      UserStatusCriterion.should_receive(:with_status).
        with conforming_user.status
      UserStatusCriterion.fulfilled_by conforming_user
    end

    it "should have fulfilled_by scope which only accepts User" do
      expect { UserStatusCriterion.fulfilled_by criterion }.
        to raise_error ArgumentError, "received UserStatusCriterion instead of User"
    end

    def test_scope(scope)
      result = UserStatusCriterion.scoped.send(scope, conforming_user.status)
      result.length.should eql 2
      result = UserStatusCriterion.scoped.send(scope, nonconforming_user.status)
      result.length.should eql 1
      result.should include permissive_criterion
    end

  end

  context "fulfillable module" do
    include_examples 'fulfillable module'
    let(:fulfiller_class) { User }
    def touch(f)
      f.statuses = %w( undergrad grad )
    end
  end

  context "fulfillable scopes and requirements" do
    include_examples 'fulfillable scopes and requirements'
    let(:membership) { create :membership, user: create( :user, status: 'undergrad' ) }
    let(:fulfillable) { create :user_status_criterion, statuses: %w( undergrad ) }
    let(:unfulfillable) { create :user_status_criterion, statuses: %w( grad temporary ) }
  end

end

