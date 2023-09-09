class FeatureNotAvailableError < StandardError; end

class FeatureFlags
  def self.virtual_open_studios?
    Conf.features['virtual_open_studios']
  end

  def self.skip_api_authorization?
    Conf.features['skip_api_authorization']
  end
end
