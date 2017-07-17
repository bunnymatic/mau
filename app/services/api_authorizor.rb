class ApiAuthorizor

  def self.authorize(request)
    auth_key = request.headers['HTTP_AUTHORIZATION']
    check_authorization_key(auth_key) || is_internal_request?(request)
  end

  def self.check_authorization_key(auth_key)
    (auth_key.present? && auth_key == Rails.application.config.api_consumer_key)
  end

  def self.is_internal_request?(request)
    begin
      referrer = URI.parse(request.env["HTTP_REFERER"].to_s)
      return false unless referrer
      request.host == referrer.host
    rescue URI::Error => ex
      false
    end

  end

end
