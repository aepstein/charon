namespace :external_registrations do
  desc "Import registrations starting from a certain update date."
  task :import => [ :environment ] do
    count = RegistrationImporter::ExternalRegistration.import
    puts "Imported #{count} external registration records."
  end
end

