class FavoritesController < ApplicationController

  def index
    @user = User.where(id: params[:id]).first
    if @user.nil? || !@user.active?
      flash[:error] = "The account you were looking for was not found."
      redirect_back_or_default(artists_path)
      return
    end

    @favorites = FavoritesCollectionPresenter.new @user.favorites, @user, current_user
  end

end
