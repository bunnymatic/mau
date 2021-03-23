module OpenStudiosSubdomain
  class ErrorController < BaseOpenStudiosController
    def index
      render 'index', status: :bad_request
    end
  end
end
