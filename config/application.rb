require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
#require "active_resource/railtie"
require "sprockets/railtie"
#require 'rails/all'

require File.expand_path('../../lib/app_config', __FILE__)

c = AppConfig.new
c.use_file! File.expand_path('../../config/config.yml', __FILE__)
c.use_file! File.expand_path('../../config/config.local.yml', __FILE__)
c.use_section! Rails.env
::Conf = c


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Mau
  class Application < Rails::Application
    # moved to bundler - check Gemfile


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Skip frameworks you're not going to use. To use Rails without a database,
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

    # Activate observers that should always be running
    #config.active_record.observers =:cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    config.time_zone = "Pacific Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # for restful_authentication
    #config.active_record.observers = :art_piece_observer, :user_observer

    # Use the memcached store with an options hash
    config.cache_store = :dalli_store, { :namespace => 'maudev'}

    app_paths = %w(lib mailers presenters paginators)
    app_paths << File.join('models', "concerns", '**')
    config.autoload_paths += app_paths.map{|path| File.join(Rails.root,'app', path)}

    POSTMARK_API_KEY = 'POSTMARK_API_TEST'

    config.action_mailer.postmark_settings = { :api_key => POSTMARK_API_KEY }
    config.action_mailer.delivery_method = :postmark

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.i18n.enforce_available_locales = true


    config.skylight.environments << 'acceptance'

    config.filter_parameters += [:password, :password_confirmation]

    config.s3_info = {
      bucket: ENV['S3_BUCKET'] || "mission-artists-#{Rails.env}",
      access_key_id: ENV['AWS_ACCESS_KEY_ID'] || 'bogus',
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] || 'bogus'
    }

  end

end

# require 'sass'
# require 'sass/plugin'
# Sass::Plugin.options[:style] = :compact
# Sass::Plugin.options[:template_location] = File.join(Rails.root, '/app/assets/stylesheets')
require 'tag_extensions'

# add custom mimetypes (for qrcode)
Mime::Type.register "image/png", :png

puts "Environment: #{Rails.env}"
