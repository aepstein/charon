require 'spec_helper'

describe Framework do

  let( :framework ) { build :framework }

  context 'validations' do
    it "should create a new instance given valid attributes" do
      framework.save!
    end

    it "should not save without a name" do
      framework.name = ""
      framework.save.should be_false
    end

    it "should not save with a name that is not unique" do
      framework.save!
      second_framework = build( :framework, name: framework.name )
      second_framework.save.should be_false
    end
  end

end

