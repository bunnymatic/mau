# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#USERAGENT = 'HTTP_USER_AGENT'
require 'faye'

class ApplicationController < ActionController::Base
  VERSION = 'Charger 6.0 '
  DEFAULT_CSV_OPTS = {:row_sep => "\n", :force_quotes => true}

  include OpenStudiosEventShim

  #helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  #include MobilizedStyles
  before_filter :append_view_paths
  before_filter :init_body_classes, :set_controller_and_action_names
  before_filter :check_browser, :unless => :format_json?
  before_filter :set_version
  before_filter :get_feeds
  before_filter :get_new_art, :unless => :format_json?
  before_filter :set_meta_info

  helper_method :current_user_session, :current_user, :logged_in?, :current_artist
  helper_method :current_open_studios
  helper_method :current_open_studios_key, :available_open_studios_keys # from OpenStudiosEventShim

  # before_filter :track_path
  # def track_path
  #   puts '%s => %s' % [request.path, request.referrer]
  # end

  def append_view_paths
    append_view_path "app/views/common"
  end
  
  def store_location
    return unless request.format == 'text/html'
    if request.post? || request.xhr?
      session[:return_to] = request.referrer
    else
      session[:return_to] = request.fullpath
    end
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

  def logout
    session[:return_to] = nil
    current_user_session.try(:destroy)
  end

  def current_artist
    current_user if current_user.try(:is_artist?)
  end

  def redirect_back_or_default(default = nil)
    path = session.delete(:return_to) || default || root_path
    redirect_to path
    session[:return_to] = nil
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def logged_in?
    !!current_user
  end

  alias :user_required :require_user

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end

  alias :logged_out_required :require_no_user

  def init_body_classes
    @body_classes ||= []
  end

  def set_controller_and_action_names
    @current_controller = controller_name
    @current_action     = action_name
  end

  def add_body_class clz
    @body_classes << clz
    @body_classes << Rails.env
    @body_classes = @body_classes.flatten.compact.uniq
  end

  def commit_is_cancel
    !params[:commit].nil? && params[:commit].downcase == 'cancel'
  end

  if !Mau::Application.config.consider_all_requests_local || Rails.env != 'development'
    #rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    #rescue_from ActionController::RoutingError,       :with => :render_not_found
    #rescue_from ActionController::UnknownController,  :with => :render_not_found
    #rescue_from ActionController::UnknownAction,      :with => :render_not_found
    #rescue_from Exception, :with => :render_error
  end

  def set_version
    @revision = VERSION
    @build = 'unk'
  end

  def get_new_art
    @new_art = ArtPiece.get_new_art.map{|ap| ArtPiecePresenter.new(view_context, ap)}
  end

  def get_feeds
    @feed_html = File.open('_cached_feeds.html','r').read() if File.exists?('_cached_feeds.html')
  end

  protected
  def is_admin?
    current_user && current_user.is_admin?
  end

  def is_editor?
    is_admin? || (current_user && current_user.is_editor?)
  end

  def is_manager?
    is_admin? || (current_user && current_user.is_manager?)
  end

  def is_artist?
    current_user && current_user.is_a?(Artist)
  end

  def admin_required
    redirect_to "/error" unless is_admin?
  end

  def artist_required
    redirect_to "/error" unless is_artist?
  end

  def editor_required
    redirect_to "/error" unless is_editor?
  end

  def manager_required
    redirect_to "/error" unless is_manager?
  end

  def editor_or_manager_required
    redirect_to "/error" unless is_manager? || is_editor?
  end

  def check_browser
    @browser_as_class = browser.name.downcase.gsub(' ', '_') #_class(self.request)

    @logo_img = (Rails.env != 'acceptance') ? "/images/tiny-colored.png" : "/images/tiny-colored-acceptance.png"
  end

  private

  def render_not_found(exception)
    logger.warn(exception)
    @exception = exception
    render :template => "/error/index", :status => 404
  end

  def render_error(exception)
    logger.error(exception)
    @exception = exception
    render :template => "/error/index", :status => 500
  end

  def render_csv_string csv_data, filename
    disposition = ['attachment']
    if filename
      filename = filename + '.csv' unless /\.csv$|\.CSV$/.match(filename)
      disposition << "filename=#{filename}"
    end
    send_data csv_data, :type => 'text/csv', :disposition => disposition.compact.join('; ')
  end

  def set_meta_info
    @page_description =<<EOF
Mission Artists United is a website dedicated to the unification of artists
in the Mission District of San Francisco.  We promote the artists and the
community. Art is the Mission!
EOF
    @page_keywords = ["art is the mission", "art", "artists","san francisco"]
  end

  def format_json?
    request.format == Mime::Type.lookup_by_extension(:json)
  end

  def is_local_referer?
    if request.referer.to_s.match(/^https?\:\/\//i)
      request.referer.to_s.match /#{request.domain}/
    else
      true
    end
  end

  def current_open_studios
    @current_open_studios ||= OpenStudiosEventPresenter.new(view_context, OpenStudiosEvent.current)
  end

end
