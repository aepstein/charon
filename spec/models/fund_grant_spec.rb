require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundGrant do

  before :each do
    @fund_grant = build(:fund_grant)
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
      duplicate = build(:fund_grant,
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

  context 'scopes' do
    it 'should have a closed scope' do
      generate_non_current_fund_grants
      FundGrant.closed.length.should eql 1
      FundGrant.closed.should include @closed
    end

    it 'should have a current scope' do
      generate_non_current_fund_grants
      FundGrant.current.length.should eql 1
      FundGrant.current.should include @fund_grant
    end
  end

  def generate_non_current_fund_grants
    @fund_grant.save!
    @closed = create(:closed_fund_grant)
    @upcoming = create(:upcoming_fund_grant)
  end

end

