module Api
  class ApiController < ActionController::Base
    before_action :require_authorization

    def require_authorization
      auth_key = request.headers['HTTP_AUTHORIZATION']
      unless internal_request? || (auth_key.present? && auth_key == Rails.application.config.api_consumer_key)
        render(text: "Unauthorized Request.  Access Denied.", status: :unauthorized) and return
      end
      true
    end

    def internal_request?
      begin
        server = Rails.application.config.action_mailer.default_url_options[:host]
        referrer = URI.parse(request.env["HTTP_REFERER"].to_s)
        referrer && referrer.host && (server.include?(referrer.host) || /^https?:\/\/127\.0\.0\.1\//)
      rescue URI::Error => ex
        false
      end

    end
  end
end
