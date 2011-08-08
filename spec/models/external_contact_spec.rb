require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'importer_tests'

describe RegistrationImporter::ExternalContact do

  include SpecImporterTests

  before(:each) do
    clean_external_registrations_db
    module ActiveRecord
      module AttributeMethods
        module Write
          def write_attribute(attr_name, value)
            # CPK
            if attr_name.kind_of?(Array)
              puts "#{attr_name}: #{value}"
              unless value.length == attr_name.length
                raise "Number of attr_names and values do not match"
              end
              [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
              value
            else
              attr_name = attr_name.to_s
              # CPK
              # attr_name = self.class.primary_key if attr_name == 'id'
              attr_name = self.class.primary_key if (attr_name == 'id' and !self.composite?)
              @attributes_cache.delete(attr_name)
              if (column = column_for_attribute(attr_name)) && column.number?
                @attributes[attr_name] = convert_number_column_value(value)
              else
                @attributes[attr_name] = value
              end
            end
          end
        end
      end
    end
    @contact = create(:external_contact)
  end

  it "should create a new instance given valid attributes" do
    @contact.id.should_not be_nil
  end

  xit 'should return appropriate values for attributes' do
    tests = [
      [:contacttype, 'PRES', eql( Role.find_or_create_by_name('president') )],
      [:contacttype, 'UKN', be_nil],
      [:contacttype, nil, be_nil]
    ]
    getter_tests(@contact, tests)
  end

  xit 'should return net_ids for the contact object' do
    @contact.netid = 'ate2'
    @contact.net_ids.should include 'ate2'
    @contact.email = 'ate2@cornell.edu'
    @contact.net_ids.should include 'ate2'
    @contact.netid = nil
    @contact.email = nil
    @contact.net_ids.should be_empty
  end

  xit 'should return user role pairs correctly' do
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

