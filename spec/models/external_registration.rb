require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec/lib/importer_tests'

describe RegistrationImporter::ExternalRegistration do

  include SpecImporterTests

  before(:each) do
    clean_external_registrations_db
    @registration = Factory(:external_registration)
  end

  it "should create a new instance given valid attributes" do
    Factory(:external_registration).new_record?.should be_false
  end

  it 'should return appropriate values for attributes' do
    tests = [
      [:reg_approved, 'YES', be_true],
      [:reg_approved, 'NO', be_false],
      [:reg_approved, nil, be_false],
      [:funding, 'SAFC,GPSAFC', eql( %w( safc gpsafc ) )],
      [:funding, '', be_empty],
      [:funding, nil, be_empty],
      [:orgtype, 'CIO', be_true],
      [:orgtype, 'UNIV', be_false],
      [:orgtype, nil, be_false],
      [:sports_club, 'YES', be_true],
      [:sports_club, 'NO', be_false],
      [:sports_club, nil, be_false]
    ]
    getter_tests(@registration, tests)
  end

  it 'should import a new record successfully' do
    import_result_test RegistrationImporter::ExternalRegistration.import, [ 1, 0, 0 ]
    @registration.reg_approved.should be_true
    @registration.reg_approved = 'NO'
    @registration.save
    @registration.reload
    @registration.reg_approved.should be_false
    import_result_test RegistrationImporter::ExternalRegistration.import, [ 0, 1, 0 ]
    import_result_test RegistrationImporter::ExternalRegistration.import, [ 0, 0, 0 ]
    @registration.destroy
    import_result_test RegistrationImporter::ExternalRegistration.import, [ 0, 0, 1 ]
  end

  it 'should manage contacts for an imported record correctly' do
    @contact = Factory(:external_contact, :registration => @registration, :netid => 'zzz999', :contacttype => 'PRES')
    import_result_test RegistrationImporter::ExternalRegistration.import, [ 1, 0, 0 ]
    import = Registration.external_id_equals(@contact.org_id).external_term_id_equals(@contact.term_id).first
    Membership.all.each do |m|
      puts "Membership: #{m.registration} #{m.user} #{m.role}"
    end
    import.users.length.should eql 1
    import.users.first.net_id.should eql 'zzz999'
  end

end

