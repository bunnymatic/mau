Mau::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  config.cache_store = :dalli_store, { :namespace => 'mauacceptance'}


  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  POSTMARK_API_KEY = Conf.POSTMARK_API_KEY

  config.action_mailer.postmark_settings = { :api_key => POSTMARK_API_KEY }
  config.action_mailer.delivery_method = :postmark

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  config.assets.compress = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( admin.js mau.css mau-ie.css mau-ie7.css mau-safari.css mau-admin.css excanvas.compiled.js gmaps/google.js mau/mau_gmap.js mau_mobile.js catalog.css event_calendar.js event_calendar.css mau-mobile.css artists_map.js)
  config.assets.precompile += %w(.svg .eot .woff .ttf)
  config.assets.paths << Rails.root.join('app/assets/components')


  config.action_mailer.default_url_options = {
    :host => 'mau-gto.rcode5.com'
  }

end
Rails.application.routes.default_url_options[:host] = 'http://mau-gto.rcode5.com'
