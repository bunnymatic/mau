# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

USERAGENT = 'HTTP_USER_AGENT'
require 'cookies_helper'
require 'mobile_fu'
require 'mobilized_styles'

@@revision = 0
class ApplicationController < ActionController::Base

  has_mobile_fu
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'mau'
  include AuthenticatedSystem
  include MobilizedStyles
  before_filter :check_browser, :set_version
  after_filter :update_cookies

  def commit_is_cancel
    !params[:commit].nil? && params[:commit].downcase == 'cancel'
  end

  def update_cookies
    @last_visit = nil;
    last_visit = DateTime::now()
    user_info = {}
    if current_user
      user_info.merge!({ :email => current_user.email,
                        :firstname => current_user.firstname,
                        :lastname => current_user.lastname,
                        :fullname => current_user.get_name(true) })
    end
    cookie_data = {:last_visit => last_visit}.merge(user_info)
    cookies[:mau] = CookiesHelper::encode_cookie(cookie_data)
    @last_visit = last_visit
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
  
  def browser_class(req) 
    ua = req.env[USERAGENT]
    if ua.include?('MSIE') || ua.include?("Trident/4.0")
      'msie'
    elsif ua.include?('AppleWebKit') || ua.include?("Safari")
      'chrome'
    elsif ua.include?('Mozilla') && ua.include?('Firefox')
      'firefox'
    else
      'unk'
    end
  end

  def is_ie8?(req)
    req.env[USERAGENT].include?('MSIE 8.0') || req.env[USERAGENT].include?("Trident/4.0")
  end
  def is_ie7?(req)
    req.env[USERAGENT].include?('MSIE 7.0') && !req.env[USERAGENT].include?("Trident/4.0")
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
    if !current_user or !current_user.is_admin?
      redirect_to "/error"
    end
  end

  def check_browser
    @_ismobile = (is_mobile_device? and is_mobile_device? > 0)? true:false
    @_mobile_device_name = user_agent_device_name 
    params[:format] = 'mobile' if @_ismobile
    logger.info("Mobile? %s (device %s)" % [@_ismobile, @_mobile_device_name])

    unless self.request[USERAGENT].blank?
      @_ie = is_ie?(self.request)
      @_ie6 = is_ie6?(self.request)
      @_ie7 = is_ie7?(self.request)
      @_ff = is_ff?(self.request)
      @_safari = is_safari?(self.request)
      @browser_as_class = browser_class(self.request)
    end
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
    response.headers["Last-Modified"] = Time.now.httpdate
    response.headers["Expires"] = "0"
    # HTTP 1.0
    response.headers["Pragma"] = "no-cache"
    # HTTP 1.1 'pre-check=0, post-check=0' (IE specific)
    response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'
  end


end
