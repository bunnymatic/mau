class ErrorController < ApplicationController
  def index
    render 'index', status: :bad_request
  end
end
