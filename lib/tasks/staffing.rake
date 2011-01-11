namespace :staffing do

  desc "Import sourced memberships from staffing database."
  task :import => [ :environment ] do
    puts "Importing sourced memberships from staffing database..."
    MemberSource.inject([0, 0, 0, 0.seconds]) do |memo, source|
    r = StaffingImporter::ExternalUser.import( source )
    memo = 0..3.map { |i| memo[i] + r[i] }
    end
    result = RegistrationImporter::ExternalTerm.import
    report_import_result( "all", "registration_terms", result )
  end

  def report_import_result( result )
    ::Rails.logger.info "Staffing: import: #{import_result result}"
    puts import_result result
  end

  def import_result( result )
    "#{result[0]} new records, #{result[1]} changed, #{result[2]} destroyed. (#{result[3]} seconds elapsed)"
  end

end

