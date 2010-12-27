# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

USERAGENT = 'HTTP_USER_AGENT'
require 'cookies_helper'

@@revision = 0
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'mau'
  include AuthenticatedSystem

  before_filter :check_browser, :set_version
  after_filter :update_cookies

  def commit_is_cancel
    !params[:commit].nil? && params[:commit].downcase == 'cancel'
  end

  def update_cookies
    @last_visit = nil;
    maucookie = CookiesHelper::decode_cookie(cookies[:mau])
    if !maucookie or maucookie.empty?
      last_visit = DateTime::now()
      cookies[:mau] = CookiesHelper::encode_cookie({ :last_visit => last_visit, :email => current_user ? current_user.email : '' })
      @last_visit = last_visit
    end
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  unless ActionController::Base.consider_all_requests_local
    filter_parameter_logging :password
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end 

  def is_ie8?(req)
    req.env[USERAGENT].include? 'MSIE 8.0'
  end
  def is_ie7?(req)
    req.env[USERAGENT].include? 'MSIE 7.0'
  end
  def is_ie6?(req)
    req.env[USERAGENT].include? 'MSIE 6.0'
  end
  def is_ie?(req)
    is_ie7?(req) or is_ie8?(req)
  end
  def is_ff?(req)
    req.env[USERAGENT].include? 'Firefox'
  end
  def is_safari?(req)
    req.env[USERAGENT].include? 'Safari'
  end

  def set_version
    @version = revision()
  end

  def revision()
    # file provided by cap deploy
    if @@revision == 0
      begin
        file = File.expand_path('REVISION')
        f = open(file,'r')
        @@revision = f.read
        f.close
      rescue
        @@revision = "unk"
      end
    end
    @@revision
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
    render :template => "/error/#{status[0,3]}.html.erb", :status => status, :layout => 'mau'
  end

  protected
  def local_request?
    true
  end

  protected
  def admin_required
    RAILS_DEFAULT_LOGGER.warn("ApplicationController: checking for admin")
    if !self.current_user or !self.current_user.is_admin?
      redirect_to "/error"
    end
  end

  def check_browser
    @_ie = is_ie?(self.request)
    @_ie6 = is_ie6?(self.request)
    @_ie7 = is_ie7?(self.request)
    @_ff = is_ff?(self.request)
    @_safari = is_safari?(self.request)
    
    # set corners
    corners = ['corner1','corner2','corner3','corner4']
    if @_ie6
      @corners = corners.collect { |c| "/images/%s.gif" % c }
      @logo_img = "/images/tiny-colored.gif"
    else
      @corners = corners.collect { |c| "/images/%s.png" % c }
      @logo_img = "/images/tiny-colored.png"
    end

    logger.debug("Browser: FF %s IE %s Safari %s" % [@_ff, @_ie, @_safari])
  end

  private

  def render_not_found(exception)
    logger.warn(exception)
    render :template => "/error/index.html.erb", :status => 404
  end

  def render_error(exception)
    logger.error(exception)
    render :template => "/error/index.html.erb", :status => 500
  end

  def no_cache
    response.headers["Last-Modified"] = Time.now.httpdate
    response.headers["Expires"] = "0"
    # HTTP 1.0
    response.headers["Pragma"] = "no-cache"
    # HTTP 1.1 'pre-check=0, post-check=0' (IE specific)
    response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'
  end


end
