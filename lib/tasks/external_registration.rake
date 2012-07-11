namespace :external_registrations do

  namespace :import do

    desc "Import registration terms."
    task :terms => [ :environment ] do
      puts "Importing all registration terms..."
      result = RegistrationImporter::ExternalTerm.import
      update_frameworks result
      report_import_result( "all", "registration_terms", result )
    end

    desc "Import registrations that changed since the last date."
    task :latest => [ :terms ] do
      puts "Importing latest registrations with contacts..."
      result = RegistrationImporter::ExternalRegistration.import :latest
      update_frameworks result
      report_import_result( "latest", "registrations", result )
    end

    desc "Import all registrations."
    task :all => [ :terms ] do
      puts "Importing all registrations with contacts..."
      result = RegistrationImporter::ExternalRegistration.import :all
      update_frameworks result
      report_import_result( "all", "registrations", result )
    end

    # If no changes occurred, skip framework update as there is no reason
    # to do it
    def update_frameworks(result)
      return true if result[0..2] == [0,0,0]
      Framework.all.each { |framework| framework.update_memberships }
    end

    def report_import_result( context, type, result )
      ::Rails.logger.info "External registrations: import: #{context} [#{type}]: #{import_result result}"
      puts import_result result
    end

    def import_result( result )
      "#{result[0]} new records, #{result[1]} changed, #{result[2]} destroyed. (#{result[3]} seconds elapsed)"
    end

  end

  desc "Alias for import:latest"
  task :import => 'import:latest'
end

