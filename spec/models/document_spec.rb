require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Document do
  before(:each) do
    @document = build(:document)
  end

  after(:each) do
    Document.all.each { |document| document.destroy }
  end

  it "should create a new instance given valid attributes" do
    @document.save!
  end

  it "should not save without an fund_edition" do
    @document.fund_edition = nil
    @document.save.should eql false
  end

  it "should not save without an document type" do
    @document.document_type = nil
    @document.save.should eql false
  end

  it "should not create if it conflicts with an existing document type for an fund_edition" do
    @document.save!
    duplicate = @document.clone
    duplicate.save.should eql false
  end

  it 'should not create if document is larger than size allowed by document type' do
    @document.save!
    @document.document_type.update_attributes!( :max_size_quantity => 200, :max_size_unit => 'byte' )
    @document.reload
    @document.original = Rack::Test::UploadedFile.new(
      "#{::Rails.root}/features/support/assets/small.pdf", 'application/pdf' )
    @document.save.should be_false
  end

end

