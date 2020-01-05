# frozen_string_literal: true

require 'digest/sha1'
require 'erb'

def site_keys_file
  File.join('config', 'initializers', 'site_keys.rb')
end

def secure_digest(*args)
  Digest::SHA1.hexdigest(args.flatten.join('--'))
end

def make_token
  secure_digest(Time.current, (1..10).map { rand.to_s })
end

def make_site_keys_rb
  site_key = secure_digest(Time.current, (1..10).map { rand.to_s })
  _site_key_erb = <<~SITEKEYS
    # key of 40 chars length
    REST_AUTH_SITE_KEY         = '#{site_key}'
    REST_AUTH_DIGEST_STRETCHES = 10
  SITEKEYS
end

namespace :auth do
  namespace :gen do
    desc 'Generates config/initializers/site_keys.rb'
    task site_key: [:environment] do
      file = ENV['file'] || site_keys_file
      File.open(file, 'w') { |f| f.write(make_site_keys_rb) }
    end
  end
end
