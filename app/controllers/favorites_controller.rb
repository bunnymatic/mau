class FavoritesController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    if @user.suspended?
      @user = nil
      flash.now[:error] = "The account you were looking for was not found."
      redirect_back_or_default("/") and return
    end
    if @user == current_user && current_user.favorites.count <= 0
      @random_picks = ArtPiece.find_random(24)
    end
  end

end
