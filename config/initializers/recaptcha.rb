# frozen_string_literal: true
require 'recaptcha'
Recaptcha.configure do |config|
  config.site_key = ::Conf.recaptcha_public_key
  config.secret_key = ::Conf.recaptcha_public_key
end

