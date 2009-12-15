# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mauweb_session',
  :secret      => '63c4cb38cfb1db660efab3e21d6581d6712858c563f0aed711d9222a6f01d98fdc80c9669b2d3b02e9cfb2a822f93c82fd44601249441be8dac317695d8b4c1c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
