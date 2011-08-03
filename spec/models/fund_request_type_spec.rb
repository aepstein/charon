require 'spec_helper'

describe FundRequestType do
  context "validation" do
    let(:fund_request_type)  { build(:fund_request_type) }

    it 'should save with valid attributes' do
      fund_request_type.save!
    end

    it 'should not save without a name' do
      fund_request_type.name = nil
      fund_request_type.save.should be_false
    end

    it 'should not save with a duplicate name' do
      fund_request_type.save!
      duplicate = build( :fund_request_type, :name => fund_request_type.name )
      duplicate.save.should be_false
    end

    it 'should not save invalid amendable_quantity_limit' do
      fund_request_type.amendable_quantity_limit = -1
      fund_request_type.save.should be_false
    end

    it 'should not save invalid appendable_quantity_limit' do
      fund_request_type.appendable_quantity_limit = -1
      fund_request_type.save.should be_false
    end

    it 'should not save invalid appendable_amount_limit' do
      fund_request_type.appendable_amount_limit = -1.0
      fund_request_type.save.should be_false
    end
  end
end

