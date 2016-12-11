class ApiAuthorizor

  def self.authorize(request)
    auth_key = request.headers['HTTP_AUTHORIZATION']
    referrer = URI.parse(request.env["HTTP_REFERER"].to_s)
    check_authorization_key(auth_key) && is_internal_request?(referrer)
  end

  def self.check_authorization_key(auth_key)
    (auth_key.present? && auth_key == Rails.application.config.api_consumer_key)
  end

  def self.is_internal_request?(referrer)
    begin
      server = Rails.application.config.action_mailer.default_url_options[:host]
      referrer && referrer.host && server.include?(referrer.host)
    rescue URI::Error => ex
      false
    end

  end

end
