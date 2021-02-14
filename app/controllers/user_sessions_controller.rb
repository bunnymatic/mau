# AuthLogic user sessions controller
class UserSessionsController < ApplicationController
  before_action :require_no_user, only: %i[new create]
  before_action :require_user, only: :destroy

  before_action :load_cms_content, only: %i[new create]

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
    flash[:notice] = 'See you next time.  Now go make some art!'
    redirect_back_or_default root_path
  end

  private

  def load_cms_content
    @cms_content = CmsDocument.packaged('signup', 'signup')
  end

  def user_session_params
    params.require(:user_session).permit(:login, :password).to_h
  end
end
