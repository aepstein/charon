require 'importer_factories'

module SpecImporterTests

  def clean_external_registrations_db
    RegistrationImporter::ExternalTerm.delete_all
    RegistrationImporter::WritableExternalRegistration.delete_all
    RegistrationImporter::WritableExternalContact.delete_all
  end

  def getter_tests(object,tests)
    tests.each do |parameters|
      object.send(:write_attribute, parameters[0], parameters[1])
      object.send(parameters[0]).should parameters[2]
    end
  end

end

