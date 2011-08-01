require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Charon
  class Application < Rails::Application
    config.autoload_paths += %W(#{::Rails.root}/lib)
    config.encoding = "utf-8"
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.default_url_options = { :host => "assembly.cornell.edu/charon", :protocol => 'https' }
    config.active_record.identity_map = true
    config.assets.enabled = true
    config.assets.precompile = ['application.js', 'application.css', 'admin.js', 'admin.css']

    def self.relative_url_root
      '/charon'
    end

    def self.app_config
      @@app_config ||= YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]
    end

  end
end

