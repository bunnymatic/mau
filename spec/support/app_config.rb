module MockAppConfig
  def mock_app_config(key, value)
    value.stringify_keys! if value.is_a? Hash
    allow(Conf).to receive(:method_missing).with(key.to_sym).and_return(value)
  end

  # if you have multiple mock_app_config calls, you need this at the end
  def mock_app_config_fallback
    # fallback for any other calls
    allow(Conf).to receive(:method_missing).and_return(nil)
  end
end

RSpec.configure do |config|
  config.include MockAppConfig
end
