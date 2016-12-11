# frozen_string_literal: true

module Api
  class ApiController < ActionController::Base
    before_action :require_authorization

    def require_authorization
      return true if ApiAuthorizor.authorize(request)
        render(plain: 'Unauthorized Request.  Access Denied.', status: :unauthorized) && return
      end
      true
    end
  end
end
