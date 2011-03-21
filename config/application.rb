require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'csv'

module Charon
  class Application < Rails::Application
    config.autoload_paths += %W(#{::Rails.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [ :password, :password_confirmation ]
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.default_url_options = { :host => "assembly.cornell.edu/charon", :protocol => 'https' }
    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ui jquery-ui-timepicker-addon autocomplete-rails rails)

    def self.relative_url_root
      '/charon'
    end

    def self.app_config
      @@app_config ||= YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]
    end

  end
end
