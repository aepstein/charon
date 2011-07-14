require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundGrant do

  before :each do
    @fund_grant = Factory.build(:fund_grant)
  end

  context 'validations' do
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
  end

  context 'accessors' do
    it "should have a retriever method for each perspective" do
      FundEdition::PERSPECTIVES.each do |perspective|
        @fund_grant.send(perspective).class.should eql Organization
      end
    end
  end

  context 'users proxy' do
    it 'should have a perspective_for method that identifies a user\'s perspective' do
      requestor_role = Factory(:requestor_role)
      reviewer_role = Factory(:reviewer_role)
      requestor_organization = Factory(:organization)
      reviewer_organization = Factory(:organization)
      requestor = Factory(:membership, :role => requestor_role, :active => true, :organization => requestor_organization).user
      conflictor = Factory(:membership, :role => requestor_role, :active => true, :organization => requestor_organization).user
      Factory(:membership, :role => reviewer_role, :active => true, :organization => reviewer_organization, :user => conflictor)
      reviewer = Factory(:membership, :role => reviewer_role, :active => true, :organization => reviewer_organization).user
      fund_source = Factory(:fund_source, :organization => reviewer_organization)
      fund_grant = Factory(:fund_grant, :fund_source => fund_source,
        :organization => requestor_organization)
      [
        [ requestor, 'requestor' ], [ conflictor, 'requestor' ], [ reviewer, 'reviewer' ],
        [ requestor_organization, 'requestor' ], [ reviewer_organization, 'reviewer' ]
      ].each do |scenario|
        fund_grant.perspective_for( scenario.first ).should eql scenario.last
      end
    end
  end

  context 'scopes' do
    it 'should have a closed scope' do
      generate_non_open_fund_grants
      FundGrant.closed.length.should eql 1
      FundGrant.closed.should include @closed
    end

    it 'should have an open scope' do
      generate_non_open_fund_grants
      FundGrant.open.length.should eql 1
      FundGrant.open.should include @fund_grant
    end
  end

  def generate_non_open_fund_grants
    @fund_grant.save!
    @closed = Factory(:closed_fund_grant)
    @upcoming = Factory(:upcoming_fund_grant)
  end

end

