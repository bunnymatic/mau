Rails.application.configure do
  config.lograge.enabled = !Rails.env.development?
end
