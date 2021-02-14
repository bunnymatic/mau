module MockAppConfig
  def mock_app_config(key, value)
    value.stringify_keys! if value.is_a? Hash
    allow(Conf).to receive(:method_missing).with(key.to_sym).and_return(value)
  end
end

RSpec.configure do |config|
  config.include MockAppConfig
end
