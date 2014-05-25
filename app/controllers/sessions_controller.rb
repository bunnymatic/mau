# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout 'mau1col'
  # render new.rhtml
  def new
    respond_to do |fmt|
      fmt.html {
        if logged_in?
          flash[:notice] = "You're already logged in"
          redirect_back_or_default('/')
        else
          @cms_content = CmsDocument.packaged('signup','signup')
        end
      }
      fmt.mobile { redirect_to "/" }
    end
  end

  def create
    respond_to do |fmt|
      fmt.html {
        logout_keeping_session!

        # try finding artist by email
        login = params[:login]
        bylogin = User.find_by_email(params[:login])
        if bylogin
          login = bylogin.login
        end

        user = User.authenticate(login, params[:password])
        if user
          # Protects against session fixation attacks, causes request forgery
          # protection if user resubmits an earlier form using back
          # button. Uncomment if you understand the tradeoffs.
          # reset_session
          if user.active?
            self.current_user = user
            # force shutoff of remember_me cookie - too agressive
            new_cookie_flag = (params[:remember_me] == "0")
            handle_remember_cookie! new_cookie_flag

            flash[:notice] = "Logged in successfully"
            redirect_back_or_default('/')
            return
          else
            note_inactive_signin
            @login       = params[:login]
            @cms_content = CmsDocument.packaged('signup','signup')
            # @remember_me = params[:remember_me]
            render :action => 'new'
          end
        else
          note_failed_signin
          @login       = params[:login]
          @cms_content = CmsDocument.packaged('signup','signup')

          # @remember_me = params[:remember_me]
          render :action => 'new'
        end
      }
      fmt.mobile { redirect_to "/" }
    end
  end
  def destroy
    mobile_view = session[:mobile_view]
    logout_killing_session!
    flash.now[:notice] = "You have been logged out."
    session[:mobile_view] = mobile_view
    redirect_back_or_default('/')
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.zone.now}"
  end
  def note_inactive_signin
    flash.now[:error] = "Couldn't log you in as '#{params[:login]}'. Have you activated your account?"
    logger.warn "Tried to login to inactive acct.'#{params[:login]}' from #{request.remote_ip} at #{Time.zone.now}"
  end
end
