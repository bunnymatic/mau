class ErrorController < ApplicationController
  skip_before_filter :get_new_art, :get_feeds

  def index
    render 'index', :status => :bad_request
  end
end
