# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#USERAGENT = 'HTTP_USER_AGENT'
require 'faye'
class ApplicationController < ActionController::Base
  #  VERSION = 'Corvair 4.3'
  VERSION = 'Dart 5.0'

  @@revision = nil

  has_mobile_fu
  #helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'mau'
  include AuthenticatedSystem
  #include MobilizedStyles
  before_filter :check_browser, :set_version, :get_feeds, :get_new_art, :set_meta_info

  def publish_page_hit
    if request.get?
      Messager.new.publish request.path, 'hit'
    end
  end

  def commit_is_cancel
    !params[:commit].nil? && params[:commit].downcase == 'cancel'
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  unless Mau::Application.config.consider_all_requests_local
    filter_parameter_logging :password
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
    rescue_from Exception, :with => :render_error
  end

  def set_version
    unless @@revision
      revision = VERSION
      build_info_file = File.join(Rails.root, 'REVISION')
      build = (File.exists?(build_info_file) ? File.open(build_info_file, 'r').read : 'unk')
      @@revision = "#{revision} [#{build}]"
    end
    @@revision
  end

  def get_new_art
    @new_art = ArtPiece.get_new_art
  end

  def get_feeds
    if File.exists?('_cached_feeds.html')
      @feed_html = File.open('_cached_feeds.html','r').read()
    end
    if @feed_html && @feed_html.length < 0
      @feed_html = "<div>Reload the page to get a new set of feeds</div>"
    end
  end

  # redirect somewhere that will eventually return back to here
  def redirect_away(*params)
    session[:original_uri] = request.request_uri
    redirect_to(*params)
  end

  # returns the person to either the original url from a redirect_away or to a default url
  def redirect_back(*params)
    uri = session[:original_uri]
    session[:original_uri] = nil
    if uri
      redirect_to uri
    else
      redirect_to(*params)
    end
  end

  protected
  def rescue_optional_error_file(status_code)
    status = interpret_status(status_code)
    render :template => "/error/#{status[0,3]}", :status => status, :layout => 'mau'
  end

  protected
  def local_request?
    true
  end

  protected
  def is_admin?
    current_user && current_user.is_admin?
  end

  def is_editor?
    is_admin? || current_user && current_user.is_editor?
  end

  def is_manager?
    is_admin? || current_user && current_user.is_manager?
  end

  def admin_required
    redirect_to "/error" unless is_admin?
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
    params[:format] = :mobile if is_mobile?
    @show_return_to_mobile = (!is_mobile? && is_mobile_device?)

    @browser_as_class = browser.name.downcase.gsub(' ', '_') #_class(self.request)

    # set corners
    if browser.ie7? || browser.ie8?
      @logo_img = "/images/tiny-colored.gif"
    else
      @logo_img = "/images/tiny-colored.png"
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

  def render_csv opts

    filename = opts[:filename] || params[:action]
    filename += '.csv' unless /\.csv$|\.CSV$/.match(filename)

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end
    render :text => Proc.new { |response, output|
      #monkey patch /duck typing. 2.3 rails ActionController::Response doesn't have <<, only write
      def output.<<(*args)
        write(*args)
      end
      csv = FasterCSV.new(output, :row_sep => "\n", :force_quotes => true)
      yield csv
    }
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
    @page_description = "Mission Artists United is a website dedicated to the unification of artists in the Mission District of San Francisco.  We promote the artists and the community. Art is the Mission!"
    @page_keywords = ["art is the mission", "art", "artists","san francisco"]
  end

  def is_local_referer?
    if request.referer.to_s.match(/^https?\:\/\//i)
      request.referer.to_s.match /#{Conf.site_url}/i
    else
      true
    end
  end
end
