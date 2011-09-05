require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Charon
  class Application < Rails::Application
    config.autoload_paths += %W(#{::Rails.root}/lib)
    config.encoding = "utf-8"
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.default_url_options = { :host => "assembly.cornell.edu/charon", :protocol => 'https' }
    config.active_record.identity_map = true
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.precompile = ['application.js', 'application.css', 'admin.js', 'admin.css']

    def self.relative_url_root
      '/charon'
    end

    def self.app_config
      @@app_config ||= YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]
    end

  end
end

