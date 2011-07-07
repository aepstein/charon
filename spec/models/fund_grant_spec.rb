require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundGrant do

  before :each do
    @fund_grant = Factory.build(:fund_grant)
  end

  it 'should save with valid attributes' do
    @fund_grant.save!
  end

  it 'should not save without an organization' do
    @fund_grant.organization = nil
    @fund_grant.save.should be_false
  end

  it 'should not save without a fund_source' do
    @fund_grant.fund_source = nil
    @fund_grant.save.should be_false
  end

  it 'should not save a duplicate fund_source for given organization' do
    @fund_grant.save!
    duplicate = Factory.build(:fund_grant,
      :organization => @fund_grant.organization,
      :fund_source => @fund_grant.fund_source )
    duplicate.save.should be_false
  end

  it 'should not save an invalid released_at value' do
    @fund_grant.save!
    @fund_grant.released_at = 'blah'
    @fund_grant.save.should be_false
  end

end

