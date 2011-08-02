require 'spec_helper'

describe DocumentType do
  before(:each) do
    @document_type = build( :document_type )
  end

  it "should create a new instance given valid attributes" do
    @document_type.save!
  end

  it "should not save with an invalid max_size_quantity" do
    @document_type.save!
    @document_type.max_size_quantity = nil
    @document_type.save.should be_false
    @document_type.max_size_quantity = 0
    @document_type.save.should be_false
    @document_type.max_size_quantity = 'roger'
    @document_type.save.should be_false
    @document_type.max_size_quantity = 10.2
    @document_type.save.should be_false
  end

  it "should not save with an invalid max_size_unit" do
    @document_type.save!
    @document_type.max_size_unit = 'invalid'
    DocumentType::UNITS.should_not include( @document_type.max_size_unit )
    @document_type.save.should be_false
  end

  it "should not save with a duplicate name" do
    @document_type.save!
    duplicate = build( :document_type, :name => @document_type.name )
    duplicate.save.should be_false
    duplicate.name = "#{duplicate.name} unique"
    duplicate.save.should be_true
  end

end

