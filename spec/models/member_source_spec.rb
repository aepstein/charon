require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MemberSource do
  before(:each) do
    @source = create(:member_source)
  end

  it 'should create a new instance given valid attributes' do
    @source.id.should_not be_nil
  end

  it 'should not save without an organization' do
    @source.organization = nil
    @source.save.should be_false
  end

  it 'should not save without a role' do
    @source.role = nil
    @source.save.should be_false
  end

  it 'should not save without or with invalid minimum_votes' do
    @source.minimum_votes = nil
    @source.save.should be_false
    @source.minimum_votes = -1
    @source.save.should be_false
    @source.minimum_votes = 2
    @source.save.should be_true
  end

  it 'should not save without or with invalid external_committee_id' do
    @source.external_committee_id = nil
    @source.save.should be_false
    @source.external_committee_id = 0
    @source.save.should be_false
    @source.external_committee_id = 1
    @source.save.should be_true
  end

end

