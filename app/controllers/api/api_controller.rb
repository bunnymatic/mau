module Api
  class ApiController < ActionController::Base
    before_filter :require_authorization

    def require_authorization
    end

  end
end
