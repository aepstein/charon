Spork.prefork do
#  require File.dirname(__FILE__) + '/../../spec/factories'
end

Spork.each_run do
  After do
    # Remove test-generated files on completion of tests
    data_directory = File.expand_path(File.dirname(__FILE__) + "../../../db/uploads/#{::Rails.env}")
    if File.directory?(data_directory)
      FileUtils.rm_rf data_directory
    end
  end

  AfterStep('@pause') do
    print "Press Return to continue ..."
    STDIN.getc
  end
end

