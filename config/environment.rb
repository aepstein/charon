RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = {
    :key => '_charon_session', :secret => Proc.new { APP_CONFIG['session_secret'] }
  }

  config.action_controller.session_store = :active_record_store

  config.time_zone = 'Eastern Time (US & Canada)'

  config.gem 'acts_as_tree', :source => 'http://gemcutter.org'
  config.gem 'authlogic', :source => 'http://gemcutter.org'
  config.gem 'calendar_date_select'
  config.gem 'will_paginate', :source => 'http://gemcutter.org'
  config.gem 'aasm', :source => 'http://gemcutter.org'
  config.gem 'paperclip', :source => 'http://gemcutter.org'
  config.gem 'validates_timeliness', :source => 'http://gemcutter.org'
  config.gem 'prawn', :source => 'http://gemcutter.org'
  config.gem 'searchlogic', :source => 'http://gemcutter.org'
  config.gem 'whenever', :source => 'http://gemcutter.org'
  config.gem 'bluecloth', :source => 'http://gemcutter.org'
  config.gem 'cornell_netid', :source => 'http://gemcutter.org'
  config.gem 'cornell_ldap', :source => 'http://gemcutter.org', :version => '>= 1.3.1'
  config.gem 'validation_reflection'
  config.gem 'formtastic', :source => 'http://gemcutter.org'
  config.gem 'declarative_authorization', :version => '>= 0.5'
  config.gem 'composite_primary_keys'
  config.gem 'sqlite3-ruby', :lib => 'sqlite3', :version => '!= 1.3.0'
  config.gem 'repeated_auto_complete', :source => 'http://gemcutter.org'

  config.action_mailer.default_url_options = { :host => "assembly.cornell.edu", :protocol => 'https' }
end

