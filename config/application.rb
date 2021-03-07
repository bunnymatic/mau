require File.expand_path('boot', __dir__)

# Unrolled `rails/all.rb` from https://github.com/rails/rails/blob/master/railties/lib/rails/all.rb as of 03/23/2020

# rubocop:disable Style/RedundantBegin
# rubocop:disable Lint/SuppressedException
require 'rails'

[
  'active_record/railtie',
  #  'active_storage/engine',
  'action_controller/railtie',
  'action_view/railtie',
  'action_mailer/railtie',
  # 'action_mailbox/engine',
  'action_text/engine',
  # 'rails/test_unit/railtie',
  #  "active_job/railtie",
  #  "action_cable/engine",
  #  "sprockets/railtie",
].each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end
# rubocop:enable Lint/SuppressedException
# rubocop:enable Style/RedundantBegin

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(*Rails.groups)
require_relative '../app/lib/app_config'

c = AppConfig.new
c.use_file! File.expand_path('../config/config.yml', __dir__)
c.use_file! File.expand_path('../config/config.local.yml', __dir__)
c.use_file! File.expand_path('../config/config.keys.yml', __dir__)
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
    config.load_defaults 6.0

    config.cache_store = :mem_cache_store, { namespace: "mau#{Rails.env}" }

    # app_paths = %w(services lib mailers presenters paginators models/concerns)
    # config.autoload_paths += app_paths.map{|path| File.join(Rails.root,'app', path)}

    config.action_mailer.delivery_method = :file

    # config.i18n.enforce_available_locales = true

    # config.filter_parameters += [:password, :password_confirmation]

    config.s3_info = {
      bucket: ::Conf.S3_BUCKET || "mission-artists-#{Rails.env}",
      access_key_id: ::Conf.AWS_ACCESS_KEY_ID || 'bogus',
      secret_access_key: ::Conf.AWS_SECRET_ACCESS_KEY || 'bogus',
      s3_region: Conf.S3_REGION || 'us-east-1',
    }

    config.api_consumer_key = ENV.fetch('API_CONSUMER_KEY', ::Conf.api_consumer_key)
    config.elasticsearch_url = ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'

    config.active_support.test_order = :random

    config.action_dispatch.tld_length = Integer(Conf.TLD_LENGTH || 1)
  end
end

Rails.autoloaders.main.ignore(Rails.root.join('app/webpack'))
