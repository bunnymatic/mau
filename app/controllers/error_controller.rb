class ErrorController < ApplicationController
  layout 'mau1col'
  def index
    render 'index', :status => :bad_request
  end
end
