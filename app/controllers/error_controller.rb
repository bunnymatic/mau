# frozen_string_literal: true
class ErrorController < ApplicationController
  def index
    render 'index', status: :bad_request
  end
end
