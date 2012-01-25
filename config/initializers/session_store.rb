# Be sure to restart your server when you modify this file.
if Charon::Application.app_config['session_store']
  Charon::Application.config.session_store :cookie_store, key: Charon::Application.app_config['session_store']
else
  Charon::Application.config.session_store :cookie_store, key: '_charon_session'
end

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Charon::Application.config.session_store :active_record_store

