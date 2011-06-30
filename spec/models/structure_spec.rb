require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Structure do
  before(:each) do
    @structure = Factory(:structure)
  end

  it "should create a new instance given valid attributes" do
    @structure.id.should_not be_nil
  end

  it 'should not save without a name' do
    @structure.name = nil
    @structure.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory.build( :structure, :name => @structure.name )
    duplicate.save.should be_false
  end

end

