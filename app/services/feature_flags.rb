class FeatureNotAvailableError < StandardError; end

class FeatureFlags
  def self.virtual_open_studios?
    Conf.features['virtual_open_studios']
  end
end
