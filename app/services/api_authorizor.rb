class ApiAuthorizor
  def self.authorized?(request)
    auth_key = request.headers['mau-api-authorization'] || request.headers['HTTP_AUTHORIZATION']
    FeatureFlags.skip_api_authorization? || valid_authorization_key?(auth_key) || internal_request?(request)
  end

  class << self
    private

    def valid_authorization_key?(auth_key)
      auth_key.present? && auth_key == Rails.application.config.api_consumer_key
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
