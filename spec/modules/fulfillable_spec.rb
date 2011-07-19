require 'spec_helper'

shared_examples 'fulfillable' do

  let( :fulfillable ) { create( described_class.to_s.underscore ) }

  context 'fulfillments' do
    it 'should have a fulfill! method' do
      fulfillable.fulfillments.clear
      fulfillable.fulfillments.fulfill!
      fulfillers = fulfillable.fulfillments.map(&:fulfiller)
      fulfillers.length.should eql 1
      fulfillers.should include fulfilled_fulfiller
    end

    it 'should have an unfulfill! method' do
      create( :fulfillment, :fulfillable => fulfillable,
        :fulfiller => unfulfilled_fulfiller )
      fulfillable.fulfillments.reset
      fulfillable.fulfillments.map(&:fulfiller).should include unfulfilled_fulfiller
      fulfillable.fulfillments.unfulfill!
      fulfillers = fulfillable.fulfillments.map(&:fulfiller)
      fulfillers.length.should eql 1
      fulfillers.should_not include unfulfilled_fulfiller
    end
  end

  context 'callbacks' do
    it 'should call fulfillments.fulfill! on save' do
      fulfillable.fulfillments.should_receive :fulfill!
      fulfillable.save!
    end
    it 'should call fulfillments.fulfill! on update' do
      fulfillable.fulfillments.should_receive :unfulfill!
      fulfillable.save!
    end
  end
end

describe RegistrationCriterion do
  before( :each ) do
    create( :eligible_registration, :organization => fulfilled_fulfiller )
  end

  it_behaves_like 'fulfillable' do
    let( :fulfilled_fulfiller ) { create( :organization ) }
    let( :unfulfilled_fulfiller ) { create( :organization ) }
  end
end

describe Agreement do
  before( :each ) do
    create( :approval, :approvable => fulfillable, :user => fulfilled_fulfiller )
  end

  it_behaves_like 'fulfillable' do
    let( :fulfilled_fulfiller ) { create( :user ) }
    let( :unfulfilled_fulfiller ) { create( :user ) }
  end
end

