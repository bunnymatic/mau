require 'thread'
require "rubygems"
require "bundler/setup"
require "nokogiri"

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require File.join("#{RAILS_ROOT}",'lib/app_config')

c = AppConfig.new
c.use_file!("#{RAILS_ROOT}/config/config.yml")
c.use_file!("#{RAILS_ROOT}/config/config.local.yml")
c.use_section!(RAILS_ENV)
::Conf = c


POSTMARK_API_KEY = 'e3ff1e94-b1a9-4ae8-aba5-2e3a8ba3692e'


Rails::Initializer.run do |config|
  # moved to bundler - check Gemfile

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # for restful_authentication
  config.active_record.observers = :art_piece_observer, :user_observer

  # Use the memcached store with an options hash
  #config.cache_store = :mem_cache_store, { :namespace => 'maudev'}

  config.autoload_paths += %W(#{Rails.root}/app/mailers)

  POSTMARK_API_KEY = 'POSTMARK_API_TEST'
  
  config.gem 'postmark-rails'
  require 'postmark-rails'
  
  config.action_mailer.postmark_api_key = POSTMARK_API_KEY
  config.action_mailer.delivery_method = :postmark

end

Sass::Plugin.options[:style] = :compact
Sass::Plugin.options[:template_location] = File.join(Rails.root, '/app/assets/stylesheets')
require 'has_many_polymorphs'
require 'tag_extensions'

# add custom mimetypes (for qrcode)
Mime::Type.register "image/png", :png

Recaptcha.configure do |config|
  config.public_key  = '6Lc9BNkSAAAAAOmI_O3g_I9ky4IFIdHnY7YDU3Gc'
  config.private_key = '6Lc9BNkSAAAAAAHJ-NxXih62VuSsqnUx3EJc91Bo'
end

puts "Environment: #{Rails.env}"

