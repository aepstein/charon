require 'spec_helper'

shared_examples 'fulfiller update_frameworks' do
  before(:each) { framework }

  let(:framework) { raise NotImplementedError }
  let(:fulfiller) { raise NotImplementedError }
  let(:unfulfiller) { raise NotImplementedError }

  def fulfill(f); raise NotImplementedError; end
  def unfulfill(f); raise NotImplementedError; end

  def fulfiller_underscore; described_class.to_s.underscore.to_sym; end
  def fulfiller_table; described_class.to_s.underscore.pluralize.to_sym; end

  it "should not fulfill a framework if it has no membership" do
    framework.send(fulfiller_table).should_not include fulfiller
  end

  it "should call update_frameworks if fulfillment change occurs" do
    fulfiller.should_receive(:update_frameworks)
    unfulfill fulfiller
    unfulfiller.should_receive(:update_frameworks)
    fulfill unfulfiller
  end

  it "should fulfill a framework it fulfills if it has a membership" do
    fulfiller.memberships << build( :membership, fulfiller_underscore => nil )
    unfulfiller.memberships << build( :membership, fulfiller_underscore => nil )
    framework.send(fulfiller_table).should include fulfiller
    framework.send(fulfiller_table).should_not include unfulfiller
  end

  it "should fulfill a framework if it fulfills after update" do
    create :membership, { fulfiller_underscore => unfulfiller }
    framework.send(fulfiller_table).should_not include unfulfiller
    fulfill unfulfiller
    framework.association(fulfiller_table).reset
    framework.send(fulfiller_table).should include unfulfiller
  end

  it "should unfulfill a framework if it no longer fulfills on update" do
    fulfiller.memberships << build( :membership, fulfiller_underscore => nil )
    framework.send(fulfiller_table).should include fulfiller
    unfulfill fulfiller
    framework.association(fulfiller_table).reset
    framework.send(fulfiller_table).should_not include fulfiller
  end

end

shared_examples 'fulfiller module' do

  it "should have a fulfillable_types class method" do
    described_class.fulfillable_types.should =~ fulfillable_types
  end

  it "should have a fulfill scope that accepts each fulfillable_type" do
    fulfillable_types.each do |type|
      fulfillable = create type.underscore
      described_class.should_receive("fulfill_#{type.underscore}").with(fulfillable)
      described_class.fulfill fulfillable
    end
  end

  it "should have a fulfill scope that raises ArgumentError on bad fulfillable" do
    expect { described_class.fulfill User.new }.to raise_error ArgumentError
  end

  it "should have a memberships relation" do
    described_class.new.association(:memberships).should_not be_nil
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

#  it 'should fulfill/unfulfill related organizations on create/update' do
#    criterion1 = create(:registration_criterion, minimal_percentage: 50,
#      type_of_member: 'undergrads', must_register: true)
#    criterion2 = create(:registration_criterion, minimal_percentage: 50,
#      type_of_member: 'undergrads', must_register: false)
#    criterion3 = create(:registration_criterion, :minimal_percentage => 50,
#      type_of_member: 'others', must_register: false)
#    organization = create(:current_registration,
#      :organization => create(:organization), :number_of_undergrads => 10,
#      :registered => true ).organization
#    registration = organization.current_registration
#    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
#    fulfillables.size.should eql 2
#    fulfillables.should include criterion1
#    fulfillables.should include criterion2
#    registration.registered = false
#    registration.save!
#    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
#    fulfillables.length.should eql 1
#    fulfillables.should include criterion2
#    registration.number_of_others = 11
#    registration.save!
#    fulfillables = registration.organization.fulfillments.map(&:fulfillable)
#    fulfillables.length.should eql 1
#    fulfillables.should include criterion3
#  end

end

