require 'spec_helper'
require 'importer_tests'

describe RegistrationImporter::ExternalTerm do

  include SpecImporterTests

  before(:each) do
    clean_external_registrations_db
    @term = create(:external_term)
  end

  it "should create a new instance given valid attributes" do
    create(:external_term).term_id.should_not be_nil
  end

  it 'should return appropriate values for attributes' do
    time = Time.zone.now
    tests = [
      [:current, 'YES', be_true],
      [:current, 'NO', be_false],
      [:current, nil, be_false]
    ]
    getter_tests(@term, tests)
  end

  it 'should import a new record successfully' do
    RegistrationImporter::ExternalTerm.import[0,3].should eql [ 1, 0, 0 ]
    @term.update_attribute :current, 'NO'
    @term.current.should be_false
    r = RegistrationImporter::ExternalTerm.import[0,3].should eql [ 0, 1, 0 ]
    @term.destroy
    RegistrationImporter::ExternalTerm.import[0,3].should eql [ 0, 0, 1 ]
  end

end

