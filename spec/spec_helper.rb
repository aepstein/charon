require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'database_cleaner'
  Dir[::Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false
    config.include ActionDispatch::TestProcess
    config.include FactoryGirl::Syntax::Methods
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner[:active_record,
        { connection: "external_registrations_#{::Rails.env}" }].
        strategy = :truncation
    end
    config.before(:each) do
      DatabaseCleaner.start
    end
    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
  $LOAD_PATH << ( File.dirname(__FILE__) + "/lib" )
end

Spork.each_run do
  #require File.dirname(__FILE__) + "/factories"
end

