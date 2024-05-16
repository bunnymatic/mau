# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# USERAGENT = 'HTTP_USER_AGENT'
class ApplicationController < ActionController::Base
  include UserControllerHelpers
  include ActiveStorage::SetCurrent

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_action :init_body_classes, :set_controller_and_action_names
  before_action :load_notifications
  before_action :check_browser, unless: :format_json?
  before_action :set_version
  before_action :set_meta_info
  before_action :set_open_studios_active

  helper_method :current_user_session, :current_user, :logged_in?, :current_artist
  helper_method :current_open_studios
  helper_method :supported_browser?

  def store_location(location = nil)
    return unless request.format == 'text/html'
    return if request.xhr?

    session[:return_to] =
      begin
        location.presence ||
          (request.post? || (request.xhr? && request.referer)) ||
          request.fullpath
      end
  end

  def logout
    session[:return_to] = nil
    current_user_session.try(:destroy)
  end

  def user_must_be_you
    user_required
    redirect_back_or_default(user_path(current_user)) unless User.find(params[:user_id]) == current_user
  end

  def redirect_back_or_default(default = nil)
    path = session.delete(:return_to) || default || root_path
    redirect_to path
    session[:return_to] = nil
  end

  def init_body_classes
    @body_classes ||= []
  end

  def set_controller_and_action_names
    @current_controller = controller_name
    @current_action     = action_name
  end

  def add_body_class(clz)
    @body_classes << clz
    @body_classes << Rails.env
    @body_classes = @body_classes.flatten.compact.uniq
  end

  def commit_is_cancel
    !params[:commit].nil? && params[:commit].casecmp('cancel').zero?
  end

  def set_version
    version = Mau::Version.new
    @revision = version.to_s
    @build = version.build
  end

  def set_open_studios_active
    current = OpenStudiosEventService.current
    @open_studios_active = current.present? ? OpenStudiosEventPresenter.new(current) : nil
  end

  protected

  def check_browser
    @browser_as_class = browser.name.downcase.tr(' ', '_')
  end

  private

  def render_not_found(exception)
    logger.warn(exception)
    @exception = exception
    render template: '/error/index', status: :not_found
  end

  def render_error(exception)
    logger.error(exception)
    @exception = exception
    render template: '/error/index', status: :internal_server_error
  end

  def render_csv_string(csv_data, filename)
    disposition = ['attachment']
    if filename
      filename += '.csv' unless /\.csv$|\.CSV$/.match?(filename)
      disposition << "filename=#{filename}"
    end
    send_data csv_data, type: 'text/csv', disposition: disposition.compact.join('; ')
  end

  def set_meta_info
    @page_description = <<~DESC
      Mission Artists is a website dedicated to the unification of artists
      in the Mission District of San Francisco.  We promote the artists and the
      community. Art is the Mission!
    DESC
    @page_keywords = ['art is the mission', 'art', 'artists', 'san francisco']
  end

  def format_json?
    request.format == Mime::Type.lookup_by_extension(:json)
  end

  def current_open_studios
    @current_open_studios ||= OpenStudiosEventPresenter.new(OpenStudiosEventService.current)
  end

  def supported_browser?
    SupportedBrowserService.supported?(request.user_agent)
  end

  def load_notifications
    @notifications = Notification.active
  end
end
