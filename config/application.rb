require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
require 'action_text/engine'
require 'action_view/railtie'
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

require_relative '../app/lib/app_config'

c = AppConfig.new
c.use_file! File.expand_path('../config/config.yml', __dir__)
c.use_file! File.expand_path('../config/config.local.yml', __dir__)
c.use_file! File.expand_path('../config/config.keys.yml', __dir__)
c.use_section! Rails.env
Conf = c

Bundler.require(*Rails.groups)

module Mau
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.action_mailer.delivery_method = :file

    config.s3_info = {
      bucket: ::Conf.S3_BUCKET || "mission-artists-#{Rails.env}",
      access_key_id: ::Conf.AWS_ACCESS_KEY_ID || 'bogus',
      secret_access_key: ::Conf.AWS_SECRET_ACCESS_KEY || 'bogus',
      s3_region: Conf.S3_REGION || 'us-east-1',
    }

    config.api_consumer_key = ENV.fetch('API_CONSUMER_KEY', ::Conf.api_consumer_key)
    config.elasticsearch_url = ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200')
    config.opensearch_url = config.elasticsearch_url

    config.active_support.test_order = :random
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess, Symbol, ActionController::Parameters]

    config.action_dispatch.tld_length = Integer(Conf.TLD_LENGTH || 1)

    config.active_storage.variant_processor = :vips

    # Without this, SVG's are served (from S3) as application/octet-stream
    # and browsers get confused.
    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']
  end
end
