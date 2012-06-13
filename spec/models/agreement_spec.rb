require 'spec_helper'

describe Agreement do

  let( :agreement ) { build :agreement }

  context 'validation' do

    it "should create a new instance given valid attributes" do
      agreement.save!
    end

    it "should not save without a name" do
      agreement.name = nil
      agreement.save.should be_false
    end

    it "should not save with a duplicate name" do
      agreement.save!
      duplicate = build(:agreement, :name => agreement.name)
      duplicate.save.should be_false
    end

    it "should not save without content" do
      agreement.content = nil
      agreement.save.should be_false
    end

  end

  context 'callbacks' do

    it "should delete associated approvals if content is changed" do
      new_name = 'new name'
      new_content = 'new content'
      agreement.name.should_not eql new_name
      agreement.content.should_not eql new_content
      agreement.save!
      create( :approval, approvable: agreement )
      agreement.approvals.reset
      agreement.name = new_name
      agreement.save!
      agreement.approvals.count.should eql 1
      agreement.content = new_content
      agreement.save!
      agreement.approvals.should be_empty
    end

  end

  context 'fulfillment scopes' do

    let( :agreement ) { create :agreement }
    let( :conforming_user ) { create( :approval, approvable: agreement ).user }
    let( :nonconforming_user ) { create :user }

    it "should have fulfilled_by scope" do
      result = Agreement.fulfilled_by( conforming_user )
      result.length.should eql 1
      result.should include agreement
      result = Agreement.fulfilled_by( nonconforming_user )
      result.length.should eql 0
    end

    it "should have a fulfilled_by scope that only accepts a User" do
      expect { Agreement.fulfilled_by agreement }.
        to raise_error ArgumentError, "received Agreement instead of User"
    end

  end
end

