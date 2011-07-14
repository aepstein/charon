require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Fulfillment do
  before(:each) do
    @fulfillment = create(:fulfillment)
  end

  it "should create a new instance given valid attributes" do
    @fulfillment.id.should_not be_nil
  end

  it 'should not save without a fulfillable' do
    @fulfillment.fulfillable = nil
    @fulfillment.save.should eql false
  end

  it 'should not save without a fulfiller' do
    @fulfillment.fulfiller = nil
    @fulfillment.save.should eql false
  end

  it 'should not save with a fulfiller that is not allowed for the fulfillable' do
    @fulfillment.fulfillable = create(:agreement)
    @fulfillment.fulfiller = create(:organization)
    @fulfillment.save.should eql false
    @fulfillment.fulfillable = create(:user_status_criterion)
    @fulfillment.save.should eql false
    @fulfillment.fulfillable = create(:registration_criterion)
    @fulfillment.fulfiller = create(:user)
    @fulfillment.save.should eql false
  end

  it 'should not save with a disallowed fulfillable' do
    @fulfillment.fulfillable = create(:agreement)
    @fulfillment.fulfiller = create(:organization)
    @fulfillment.save.should eql false
  end
end

