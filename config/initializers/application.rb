APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/application.yml")[RAILS_ENV]
require 'organization_name_handling'

