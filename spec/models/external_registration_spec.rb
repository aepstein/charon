require 'spec_helper'
require 'importer_tests'

describe RegistrationImporter::ExternalRegistration do

  include SpecImporterTests

  before(:each) do
    clean_external_registrations_db
    @registration = create(:external_registration)
  end

  it "should create a new instance given valid attributes" do
    create(:external_registration).new_record?.should be_false
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
    RegistrationImporter::ExternalRegistration.import[0,3].should eql [ 1, 0, 0 ]
    import = Registration.first
    import.registered?.should be_true
    @registration.update_attribute :reg_approved, 'NO'
    RegistrationImporter::ExternalRegistration.import[0,3].should eql [ 0, 1, 0 ]
    RegistrationImporter::ExternalRegistration.import[0,3].should eql [ 0, 0, 0 ]
    RegistrationImporter::ExternalRegistration.import(:latest)[0,3].should eql [ 0, 0, 0 ]
    import.reload
    import.registered?.should be_false
    @registration.destroy
    RegistrationImporter::ExternalRegistration.import[0,3].should eql [ 0, 0, 1 ]
    Registration.all.should be_empty
  end

  it 'should manage contacts for an imported record correctly' do
    @contact = create(:external_contact, :registration => @registration, :netid => 'zzz999', :contacttype => 'PRES')
    RegistrationImporter::ExternalRegistration.import[0,3].should eql [ 1, 0, 0 ]
    import = Registration.where( :external_id => @contact.org_id, :external_term_id => @contact.term_id).first
    import.users.length.should eql 1
    import.users.first.net_id.should eql 'zzz999'
    @contact.update_attribute :netid, 'zzz998'
    RegistrationImporter::ExternalRegistration.import(:all)[0,3].should eql [ 0, 1, 0 ]
    RegistrationImporter::ExternalRegistration.import(:all)[0,3].should eql [ 0, 0, 0 ]
    import.reload
    import.users.length.should eql 1
    import.users.first.net_id.should eql 'zzz998'
    @contact.destroy
    RegistrationImporter::ExternalRegistration.import(:all)[0,3].should eql [ 0, 1, 0 ]
    import.reload
    import.users.should be_empty
  end

  it 'should have an importable scope that only identifies the latest records' do
    @registration.update_attribute(:updated_time, Time.zone.now.to_i)
    Registration.unscoped.count.should eql 0
    RegistrationImporter::ExternalRegistration.importable.length.should eql 1
    RegistrationImporter::ExternalRegistration.import
    RegistrationImporter::ExternalRegistration.importable.length.should eql 0
    newer = create(:external_registration, :updated_time => @registration.updated_time + 1)
    RegistrationImporter::ExternalRegistration.importable.length.should eql 1
    RegistrationImporter::ExternalRegistration.import
    RegistrationImporter::ExternalRegistration.importable.length.should eql 0
    newer.update_attribute(:updated_time, @registration.updated_time + 5)
    RegistrationImporter::ExternalRegistration.importable.length.should eql 1
    RegistrationImporter::ExternalRegistration.importable.should include newer
  end

end

