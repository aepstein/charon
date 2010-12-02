require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec/lib/importer_tests'

describe RegistrationImporter::ExternalTerm do

  include SpecImporterTests

  before(:each) do
    clean_external_registrations_db
    @term = Factory(:external_term)
  end

  it "should create a new instance given valid attributes" do
    Factory(:external_term).term_id.should_not be_nil
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
    import_result_test RegistrationImporter::ExternalTerm.import, [ 1, 0, 0 ]
    @term.current = 'NO'
    @term.current_changed?.should be_true
    @term.save
    import_result_test RegistrationImporter::ExternalTerm.import, [ 0, 1, 0 ]
    @term.destroy
    import_result_test RegistrationImporter::ExternalTerm.import, [ 0, 0, 1 ]
  end

end

