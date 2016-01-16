require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../app/lib/app_config.rb'

c = AppConfig.new
c.use_file! File.expand_path('../../config/config.yml', __FILE__)
c.use_file! File.expand_path('../../config/config.local.yml', __FILE__)
c.use_file! File.expand_path('../../config/config.keys.yml', __FILE__)
c.use_section! Rails.env
::Conf = c

module Mau
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.cache_store = :dalli_store, { :namespace => "mau#{Rails.env}"}

    #app_paths = %w(services lib mailers presenters paginators models/concerns)
    #config.autoload_paths += app_paths.map{|path| File.join(Rails.root,'app', path)}

    config.action_mailer.delivery_method = :file

    # Enable the asset pipeline
    # config.assets.enabled = true
    # config.assets.initialize_on_precompile = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.3'

    # config.i18n.enforce_available_locales = true

    # config.filter_parameters += [:password, :password_confirmation]

    # # move to strong params
    # config.active_record.whitelist_attributes = false
    config.active_record.raise_in_transactional_callbacks = true

    config.s3_info = {
      bucket: ::Conf.S3_BUCKET || "mission-artists-#{Rails.env}",
      access_key_id: ::Conf.AWS_ACCESS_KEY_ID || 'bogus',
      secret_access_key: ::Conf.AWS_SECRET_ACCESS_KEY || 'bogus'
    }

    config.api_consumer_key = ENV.fetch("API_CONSUMER_KEY", ::Conf.api_consumer_key)
    config.elasticsearch_url = ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'

    config.active_support.test_order = :random
  end
end
