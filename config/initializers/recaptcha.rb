Recaptcha.configure do |config|
  config.public_key  = ::Conf.recaptcha_public_key
  config.private_key = ::Conf.recaptcha_private_key
end

