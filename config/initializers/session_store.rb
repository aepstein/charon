# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_charon_session',
  :secret      => '13e10796e9f539c7f8accbdf897ef782f93bcb16a3ad92df9cc40342963b432e36208b4ba1c4fa39497956c7378176f5215cb677fea5d354b6c84ee171640c09'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
