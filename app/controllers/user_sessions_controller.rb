# AuthLogic user sessions controller
class UserSessionsController < ApplicationController

  layout 'mau1col'

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  before_filter :load_cms_content, :only => [:new, :create]

  def new
    respond_to do |fmt|
      fmt.html {
        @user_session = UserSession.new
      }
      fmt.mobile {
        redirect_to root_path
      }
    end
  end

  def create
    respond_to do |fmt|
      fmt.html {
        @user_session = UserSession.new(params[:user_session])
        if @user_session.save
          flash[:notice] = "You're in!"
          redirect_back_or_default root_url
        else
          flash[:warning] = "We were unable to log you in.  Check your username and password and try again."
          render :new
        end
      }
      fmt.mobile {
        redirect_to root_url
      }
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

  private
  def load_cms_content
    @cms_content = CmsDocument.packaged('signup','signup')
  end

end
