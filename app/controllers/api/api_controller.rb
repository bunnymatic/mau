module Api
  class ApiController < ActionController::Base
    before_filter :require_authorization

    def require_authorization
      auth_key = request.headers['HTTP_AUTHORIZATION']
      unless !outside_request? || (auth_key.present? && auth_key == Conf.api_consumer_key)
       render(text: "Unauthorized Request.  Access Denied.", status: :unauthorized) and return
      end
    end

    def outside_request?
      begin
        request.env["HTTP_REFERER"].nil? || (request.host != URI.parse(request.env["HTTP_REFERER"]).host)
      rescue URI::Error => ex
        true
      end

    end
  end
end
