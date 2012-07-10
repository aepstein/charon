require 'spec_helper'

shared_examples 'fulfillable' do

  let( :fulfillable ) { create( described_class.to_s.underscore ) }

  context 'class methods' do
    it "should have fulfiller_type" do
      fulfillable.class.fulfiller_type.should eql fulfiller_type
    end

    it "should have fulfiller_class" do
      fulfillable.class.fulfiller_class.should eql fulfiller_class
    end
  end

  context 'callbacks' do
    it 'should call frameworks.update! on save' do
      fulfillable.association(:frameworks).should_receive :update!
      fulfillable.save!
    end
    it 'should call frameworks.update! on destroy' do
      fulfillable.association(:frameworks).should_receive :update!
      fulfillable.destroy!
    end
  end
end

describe RegistrationCriterion do
  before( :each ) do
    create( :eligible_registration, :organization => fulfilled_fulfiller )
  end

  it_behaves_like 'fulfillable' do
    let( :fulfiller_type ) { 'Organization' }
    let( :fulfiller_class ) { Organization }
    let( :fulfilled_fulfiller ) { create( :organization ) }
    let( :unfulfilled_fulfiller ) { create( :organization ) }
  end
end

describe Agreement do
  before( :each ) do
    create( :approval, :approvable => fulfillable, :user => fulfilled_fulfiller )
  end

  it_behaves_like 'fulfillable' do
    let( :fulfiller_type ) { 'User' }
    let( :fulfiller_class ) { User }
    let( :fulfilled_fulfiller ) { create( :user ) }
    let( :unfulfilled_fulfiller ) { create( :user ) }
  end
end

