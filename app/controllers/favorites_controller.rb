class FavoritesController < ApplicationController

  def index
    @user = User.where(id: params[:user_id]).first
    if @user.nil? || !@user.active?
      flash[:error] = "The account you were looking for was not found."
      redirect_back_or_default(artists_path)
      return
    end
    if @user == current_user && current_user.favorites.count <= 0
      @random_picks = ArtPiece.find_random(24)
    end
  end

end
