require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec/lib/importer_tests'

describe RegistrationImporter::ExternalContact do

  include SpecImporterTests

  before(:each) do
    clean_external_registrations_db
    @contact = Factory(:external_contact)
  end

  it "should create a new instance given valid attributes" do
    Factory(:external_contact).new_record?.should be_false
  end

  it 'should return appropriate values for attributes' do
    tests = [
      [:contacttype, 'PRES', eql( Role.find_or_create_by_name('president') )],
      [:contacttype, 'UKN', be_nil],
      [:contacttype, nil, be_nil]
    ]
    getter_tests(@contact, tests)
  end

  it 'should return net_ids for the contact object' do
    @contact.netid = 'ate2'
    @contact.net_ids.should include 'ate2'
    @contact.email = 'ate2@cornell.edu'
    @contact.net_ids.should include 'ate2'
    @contact.netid = nil
    @contact.email = nil
    @contact.net_ids.should be_empty
  end

  it 'should return user role pairs correctly' do
    @contact.netid = 'zzz555/zzz556'
    @contact.email = 'user@example.com'
    @contact.lastname = 'Special'
    @contact.contacttype = 'PRES'
    users = @contact.users
    role = Role.find_by_name 'president'
    users.size.should eql 2
    users.should include [ role, User.find_by_net_id('zzz555') ]
    users.should include [ role, User.find_by_net_id('zzz556') ]
    users.first.last.last_name.should eql 'Special'
    users.first.last.email.should eql 'zzz555@cornell.edu'
  end

end

