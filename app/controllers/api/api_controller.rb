module Api
  class ApiController < ApplicationController
    before_action :require_authorization, :add_x_robots_header

    helper_method :current_user_session, :current_user

    include JsonapiSerializerConcerns

    def add_x_robots_header
      response.set_header('X-Robots-Tag', 'noindex')
    end

    def current_user_session
      return @current_user_session if defined? @current_user_session

      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined? @current_user

      @current_user = current_user_session.try(:user)
    end

    def require_authorization
      return true if ApiAuthorizor.authorize(request)

      render(plain: 'Unauthorized Request.  Access Denied.', status: :unauthorized) && return
    end
  end
end
