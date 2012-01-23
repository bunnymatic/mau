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
  config.cache_store = :mem_cache_store, { :namespace => 'maudev'}

  config.autoload_paths += %W(#{Rails.root}/app/mailers)
end

require 'has_many_polymorphs'
require 'tag_extensions'

puts "Environment: #{RAILS_ENV}"
