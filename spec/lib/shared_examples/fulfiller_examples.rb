require 'spec_helper'

shared_examples 'fulfiller update_frameworks' do
  before(:each) { framework }

  let(:framework) { raise NotImplementedError }
  let(:fulfiller) { raise NotImplementedError }
  let(:unfulfiller) { raise NotImplementedError }


  def fulfill(f); raise NotImplementedError; end
  def unfulfill(f); raise NotImplementedError; end

  def fulfiller_table; described_class.to_s.underscore.pluralize.to_sym; end

  def fulfiller_to_membership(f); f; end
  def fulfiller_to_reflection(f); f; end
  def build_membership; build :membership; end

  it "should not fulfill a framework if it has no membership" do
    framework.send(fulfiller_table).should_not include fulfiller
  end

  it "should call update_frameworks if fulfillment change occurs" do
    fulfiller_to_reflection( fulfiller ).should_receive(:update_frameworks)
    unfulfill fulfiller
    fulfiller_to_reflection( unfulfiller ).should_receive(:update_frameworks)
    fulfill unfulfiller
  end

  it "should fulfill a framework it fulfills if it has a membership" do
    # TODO does this test really belong here? The behavior is in membership.
    fulfiller_to_membership( fulfiller ).memberships << build_membership
    fulfiller_to_membership( unfulfiller ).memberships << build_membership
    framework.send(fulfiller_table).should include fulfiller
    framework.send(fulfiller_table).should_not include unfulfiller
  end

  it "should not fulfill a framework it fulfills if in a skip_update_frameworks block" do
    Framework.skip_update_frameworks do
      fulfiller_to_membership( fulfiller ).memberships << build_membership
      fulfiller_to_membership( unfulfiller ).memberships << build_membership
    end
    framework.send(fulfiller_table).should_not include fulfiller
  end

  it "should fulfill a framework if it fulfills after update" do
#    create :membership, { fulfiller_underscore => fulfiller_to_membership( unfulfiller ) }
    fulfiller_to_membership( unfulfiller ).memberships << build_membership
    framework.send(fulfiller_table).should_not include unfulfiller
    fulfill unfulfiller
    framework.association(fulfiller_table).reset
    framework.send(fulfiller_table).should include unfulfiller
  end

  it "should not fulfill a framework if it fulfills after update but is in skip_update_frameworks block" do
#    create :membership, { fulfiller_underscore => fulfiller_to_membership( unfulfiller ) }
    fulfiller_to_membership( unfulfiller ).memberships << build_membership
    framework.send(fulfiller_table).should_not include unfulfiller
    Framework.skip_update_frameworks do
      fulfill unfulfiller
    end
    framework.association(fulfiller_table).reset
    framework.send(fulfiller_table).should_not include unfulfiller
  end

  it "should unfulfill a framework if it no longer fulfills on update" do
    fulfiller_to_membership( fulfiller ).memberships << build_membership
    framework.send(fulfiller_table).should include fulfiller
    unfulfill fulfiller
    framework.association(fulfiller_table).reset
    framework.send(fulfiller_table).should_not include fulfiller
  end

  it "should not unfulfill a framework if it no longer fulfills on update but is in skip_update_frameworks block" do
    fulfiller_to_membership( fulfiller ).memberships << build_membership
    framework.send(fulfiller_table).should include fulfiller
    Framework.skip_update_frameworks do
      unfulfill fulfiller
    end
    framework.association(fulfiller_table).reset
    framework.send(fulfiller_table).should include fulfiller
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

end

