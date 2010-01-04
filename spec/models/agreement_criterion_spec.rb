require 'spec_helper'

describe AgreementCriterion do
  before(:each) do
    @valid_attributes = {
      :agreement_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    AgreementCriterion.create!(@valid_attributes)
  end
end
