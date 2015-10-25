module Api
  class ApiController < ActionController::Base
    before_filter :require_authorization

    def require_authorization
      auth_key = request.headers['HTTP_AUTHORIZATION']
      unless auth_key.present? && auth_key == Conf.api_consumer_key
       render(text: "Unauthorized Request.  Access Denied.", status: :unauthorized) and return
      end
    end

  end
end
