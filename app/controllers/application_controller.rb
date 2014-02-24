# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#USERAGENT = 'HTTP_USER_AGENT'
require 'faye'
class ApplicationController < ActionController::Base
  VERSION = 'Charger 6.0'
  DEFAULT_CSV_OPTS = {:row_sep => "\n", :force_quotes => true}

  has_mobile_fu
  #helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'mau'
  include AuthenticatedSystem

  #include MobilizedStyles
  before_filter :check_browser, :unless => :format_json?
  before_filter :set_version
  before_filter :get_feeds
  before_filter :get_new_art, :unless => :format_json?
  before_filter :set_meta_info

  def commit_is_cancel
    !params[:commit].nil? && params[:commit].downcase == 'cancel'
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  unless Mau::Application.config.consider_all_requests_local
    #filter_parameter_logging :password
    #rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    #rescue_from ActionController::RoutingError,       :with => :render_not_found
    #rescue_from ActionController::UnknownController,  :with => :render_not_found
    #rescue_from ActionController::UnknownAction,      :with => :render_not_found
    rescue_from Exception, :with => :render_error
  end

  def set_version
    unless @revision
      revision = VERSION
      build_info_file = File.join(Rails.root, 'REVISION')
      build = (File.exists?(build_info_file) ? File.open(build_info_file, 'r').read : 'unk')
      @revision = revision
      @build = build
    end
    [@revision, @build].join ' '
  end

  def get_new_art
    @new_art = ArtPiece.get_new_art
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

  def is_mobile?
    !!(is_mobile_device? && session[:mobile_view])
  end

  def check_browser
    request.format = :mobile if is_mobile?
    @show_return_to_mobile = (!is_mobile? && is_mobile_device?)

    @browser_as_class = browser.name.downcase.gsub(' ', '_') #_class(self.request)

    # set corners
    if browser.ie7? || browser.ie8?
      @logo_img = "/images/tiny-colored.gif"
    else
      @logo_img = (Rails.env != 'acceptance') ? "/images/tiny-colored.png" : "/images/tiny-colored-acceptance.png"
    end
  end

  private

  def render_not_found(exception)
    logger.warn(exception)
    @exception = exception
    respond_to do |fmt|
      fmt.html { render :template => "/error/index", :status => 404 }
      fmt.mobile { render :layout => 'mobile', :template => '/error/index', :status => 404 }
    end
  end

  def render_error(exception)
    logger.error(exception)
    @exception = exception
    respond_to do |fmt|
      fmt.html { render :layout => 'mau2col', :template => "/error/index", :status => 500}
      fmt.mobile { render :layout => 'mobile', :template => '/error/index', :status => 500}
    end
  end

  def render_csv_string csv_data, filename
    disposition = ['attachment']
    if filename
      filename = filename + '.csv' unless /\.csv$|\.CSV$/.match(filename)
      disposition << "filename=#{filename}"
    end
    send_data csv_data, :type => 'text/csv', :disposition => disposition.compact.join('; ')
  end

  def no_cache
    response.headers["Last-Modified"] = Time.zone.now.httpdate
    response.headers["Expires"] = "0"
    # HTTP 1.0
    response.headers["Pragma"] = "no-cache"
    # HTTP 1.1 'pre-check=0, post-check=0' (IE specific)
    response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'
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

  def logged_out_required
    redirect_to (current_artist || user_path(current_user)) if current_user
  end

end
