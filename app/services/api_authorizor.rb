class ApiAuthorizor
  def self.authorize(request)
    auth_key = request.headers['HTTP_AUTHORIZATION']
    FeatureFlags.skip_api_authorization? || check_authorization_key(auth_key) || internal_request?(request)
  end

  class << self
    private

    def check_authorization_key(auth_key)
      (auth_key.present? && auth_key == Rails.application.config.api_consumer_key)
    end

    def internal_request?(request)
      referrer = URI.parse(request.env['HTTP_REFERER'].to_s)
      return false unless referrer

      request.host == referrer.host
    rescue URI::Error
      false
    end
  end
end
