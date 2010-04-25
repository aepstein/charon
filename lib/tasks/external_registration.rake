namespace :external_registrations do

  namespace :import do

    desc "Import registrations that changed since the last date."
    task :latest => [ :environment ] do
      count = RegistrationImporter::ExternalRegistration.import
      puts "Imported #{count.first} external registration records.  Deleted #{count.last} defunct local registrations."
    end

    desc "Import all registrations."
    task :all => [ :environment ] do
      count = RegistrationImporter::ExternalRegistration.import RegistrationImporter::ExternalRegistration.all
      puts "Imported #{count.first} external registration records.  Deleted #{count.last} defunct local registrations."
    end

  end

  desc "Alias for import:latest"
  task :import => 'import:latest'
end

