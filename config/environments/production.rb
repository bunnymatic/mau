Mau::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

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

  POSTMARK_API_KEY = 'e3ff1e94-b1a9-4ae8-aba5-2e3a8ba3692e'

  config.action_mailer.postmark_settings = { :api_key => POSTMARK_API_KEY }
  config.action_mailer.delivery_method = :postmark
end
