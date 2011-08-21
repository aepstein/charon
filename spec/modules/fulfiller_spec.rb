require 'spec_helper'

shared_examples "fulfiller" do
  let(:fulfiller) { create( described_class.to_s.underscore ) }
  let(:no_requirements_framework) { create( :framework ) }
  let( :fulfilled_requirement ) {
    create( :requestor_requirement, :fulfillable => fulfilled_fulfillable )
  }
  let( :unfulfilled_requirement ) {
    create( :requestor_requirement, :fulfillable => unfulfilled_fulfillable )
  }

  before(:each) do
    fulfilled_fulfillable
    unfulfilled_fulfillable
    fulfilled_requirement
    unfulfilled_requirement
    no_requirements_framework
  end

  context 'fulfillments' do
    it 'should have a fulfill! method' do
      fulfiller.fulfillments.clear
      fulfiller.fulfillments.fulfill!
      fulfillables = fulfiller.fulfillments.map(&:fulfillable)
      fulfillables.length.should eql 1
      fulfillables.should include fulfilled_fulfillable
    end

    it 'should have an unfulfill! method' do
      create( :fulfillment, :fulfiller => fulfiller,
        :fulfillable => unfulfilled_fulfillable )
      fulfiller.fulfillments.reset
      fulfiller.fulfillments.length.should eql 2
      fulfiller.fulfillments.unfulfill!
      fulfiller.fulfillments.length.should eql 1
      fulfiller.fulfillments.should_not include unfulfilled_fulfillable
    end
  end

  context 'instance methods' do
    it 'should have a fulfilled_requirements method' do
      fulfiller.fulfilled_requirements( Requirement.scoped ).length.
        should eql 1
      fulfiller.fulfilled_requirements( Requirement.scoped ).
        should include fulfilled_requirement
    end

    it 'should have a unfulfilled_requirements method' do
      fulfiller.unfulfilled_requirements( Requirement.scoped ).length.
        should eql 1
      fulfiller.unfulfilled_requirements( Requirement.scoped ).
        should include unfulfilled_requirement
    end

    it 'should have a frameworks method' do
      fulfiller.frameworks('requestor').length.should eql 2
      fulfiller.frameworks('requestor').
        should include fulfilled_requirement.framework
      fulfiller.frameworks('requestor').
        should include no_requirements_framework
      fulfiller.frameworks('reviewer').length.should eql 3
    end
  end

  context 'callbacks' do
    xit 'should call fulfillments.fulfill! after save' do
      fulfiller.association(:fulfillments).proxy.should_receive :fulfill!
      fulfiller.save!
    end

    xit 'should call fulfillments.unfulfill! after update' do
      fulfiller.association(:fulfillments).proxy.should_receive :unfulfill!
      fulfiller.save!
    end
  end
end

describe Organization do
  before(:each) do
    create( :eligible_registration, :organization => fulfiller )
    fulfiller.reload
  end

  it_behaves_like 'fulfiller' do
    let( :fulfilled_fulfillable ) {
      create( :registration_criterion )
    }
    let( :unfulfilled_fulfillable ) {
      create( :registration_criterion, :type_of_member => 'grads' )
    }
  end
end

describe User do
  before(:each) do
    create( :approval, :user => fulfiller, :approvable => fulfilled_fulfillable )
    fulfiller.reload
  end

  it_behaves_like 'fulfiller' do
    let( :fulfilled_fulfillable ) {
      create( :agreement )
    }
    let( :unfulfilled_fulfillable ) {
      create( :agreement )
    }
  end
end

