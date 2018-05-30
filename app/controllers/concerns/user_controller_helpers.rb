# frozen_string_literal: true

module UserControllerHelpers
  extend ActiveSupport::Concern

  def current_artist
    current_user if current_user.try(:artist?)
  end

  def logged_in?
    !!current_user
  end

  def current_user_session
    return @current_user_session if defined? @current_user_session
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = current_user_session.try(:user)
  end

  def user_required
    return if current_user

    if request.xhr?
      render json: { message: 'You need to be logged in' }, status: 400
    else
      store_location
      flash[:notice] = 'You must be logged in to access this page'
      redirect_to new_user_session_url
    end
  end

  alias require_user user_required

  def require_no_user
    return unless current_user

    store_location
    flash[:notice] = 'You must be logged out to access this page'
    redirect_to(root_url) && (return false)
  end

  alias logged_out_required require_no_user

  protected

  def admin?
    current_user.try(:admin?)
  end

  def editor?
    current_user.try(:editor?)
  end

  def manager?
    current_user.try(:manager?)
  end

  def artist?
    current_user.try(:artist?)
  end

  def admin_required
    redirect_to_error_unauthorized unless admin?
  end

  def artist_required
    redirect_to_error_unauthorized unless artist?
  end

  def editor_required
    redirect_to_error_unauthorized unless editor?
  end

  def manager_required
    redirect_to_error_unauthorized unless manager?
  end

  def editor_or_manager_required
    redirect_to_error_unauthorized unless manager? || editor?
  end

  def redirect_to_error_unauthorized
    redirect_to '/error', status: :unauthorized
  end

  module ClassMethods
  end
end
