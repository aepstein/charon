shared_examples 'fulfillable update_frameworks' do
  # TODO
end

shared_examples 'fulfillable module' do
  let(:fulfiller_type) { fulfiller_class.to_s }

  it "should have correct fulfillable_type" do
    described_class.fulfiller_type.should eql fulfiller_type
  end

  it "should have correct fulfillable_class" do
    described_class.fulfiller_class.to_s.should eql fulfiller_class.to_s
  end

  it "should call update_memberships on update" do
    fulfillable = create(described_class.to_s.underscore.to_sym)
    fulfillable.should_receive :update_frameworks
    touch( fulfillable )
    fulfillable.save!
  end
# TODO move these to shared example
#  it 'should correctly fulfill users on create and update' do
#    fulfilled = user_with_status 'grad'
#    unfulfilled = user_with_status 'temporary'
#    fulfilled.status.should_not eql unfulfilled.status
#    criterion = create(:user_status_criterion, :statuses => [fulfilled.status])
#    criterion.fulfillments.size.should eql 1
#    criterion.fulfillments.first.fulfiller_id.should eql fulfilled.id
#    criterion.statuses = [unfulfilled.status]
#    criterion.save.should eql true
#    criterion.fulfillments.size.should eql 1
#    criterion.fulfillments.first.fulfiller_id.should eql unfulfilled.id
#  end

#  it 'should return a fulfiller_type of "User"' do
#    UserStatusCriterion.fulfiller_type.should eql 'User'
#  end

end

