# AuthLogic user sessions controller
class UserSessionsController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  before_filter :load_cms_content, :only => [:new, :create]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params)
    if @user_session.save
      flash[:notice] = "You're in!"
      redirect_back_or_default root_url
    else
      render :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "See you next time.  Now go make some art!"
    redirect_back_or_default root_path
  end

  private
  def load_cms_content
    @cms_content = CmsDocument.packaged('signup','signup')
  end

  def user_session_params
    params[:user_session]
  end
end
