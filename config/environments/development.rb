require 'active_support/core_ext/integer/time'
ENVIRONMENT_HOST = 'localhost:3000'.freeze

Rails.application.configure do
  # Configure 'rails notes' to inspect Cucumber files
  config.annotations.register_directories('features')
  config.annotations.register_extensions('feature') { |tag| /#\s*(#{tag}):?\s*(.*)$/ }

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.cache_classes = true

    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800',
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = {
    host: ENVIRONMENT_HOST,
  }
  config.action_controller.default_url_options = {
    host: ENVIRONMENT_HOST,
  }

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_controller.asset_host = ENVIRONMENT_HOST
  config.action_mailer.asset_host = ENVIRONMENT_HOST

  #  config.middleware.use DisableAnimations
  #

  config.hosts << 'example.org'
  config.hosts << 'mau.local'
  config.hosts << 'openstudios.mau.local'
  config.hosts << 'www.mau.local'

  config.active_storage.service = :amazon
end

Rails.application.routes.default_url_options[:host] = ENVIRONMENT_HOST
