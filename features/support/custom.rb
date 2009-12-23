After do
  # Remove test-generated files on completion of tests
  data_directory = File.expand_path(File.dirname(__FILE__) + "../../../db/uploads/#{ENV['RAILS_ENV']}")
  if File.directory?(data_directory)
    puts "Last test generated data in data directory.  Scrubbing data directory: #{data_directory}..."
    FileUtils.rm_rf data_directory
  end
end

