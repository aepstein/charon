module SpecImporterTests

  def clean_external_registrations_db
    RegistrationImporter::ExternalTerm.delete_all
    RegistrationImporter::ExternalRegistration.delete_all
    RegistrationImporter::ExternalContact.delete_all
  end

  def getter_tests(object,tests)
    tests.each do |parameters|
      object.send(:write_attribute, parameters[0], parameters[1])
      object.send(parameters[0]).should parameters[2]
    end
  end

  def import_result_test(actual,expected)
    expected.each_index do |i|
      actual[ i ].should eql expected[ i ]
    end
  end

end

