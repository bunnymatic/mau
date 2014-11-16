Mau::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  config.cache_store = :dalli_store, { :namespace => 'mauprod'}


  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  #config.cache_store = :mem_cache_store, { :namespace => 'mau'}
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  config.action_mailer.postmark_settings = { :api_key => Conf.POSTMARK_API_KEY }
  config.action_mailer.delivery_method = :postmark

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  # Generate digests for assets URLs
  config.assets.digest = true

  config.assets.compress = true

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( admin.js mau.css mau-ie.css mau-ie7.css mau-safari.css mau-admin.css excanvas.compiled.js gmaps/google.js mau/mau_gmap.js mau_mobile.js catalog.css event_calendar.js event_calendar.css mau-mobile.css artists_map.js)

  config.action_mailer.default_url_options = {
    :host => 'www.missionartistsunited.org'
  }

  config.action_controller.asset_host = "http://d2wr4fo4molwfy.cloudfront.net"

end
