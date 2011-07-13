require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require File.dirname(__FILE__) + "/factories"
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false
    config.include ActionDispatch::TestProcess
    config.before(:each) do
      DatabaseCleaner.strategy = :truncation, {:except => %w[ neighborhoods ]}
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
end

