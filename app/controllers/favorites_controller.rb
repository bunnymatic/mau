class FavoritesController < ApplicationController
  before_filter :user_required, only: [:create, :destroy]
  before_filter :user_must_be_you, only: [:create, :destroy]

  def index
    @user = begin
              User.find(params[:id])
            rescue ActiveRecord::RecordNotFound
              nil
            end
    if @user.nil? || !@user.active?
      flash[:error] = "The account you were looking for was not found."
      redirect_back_or_default(artists_path)
      return
    end

    @favorites = FavoritesCollectionPresenter.new @user.favorites, @user, current_user
  end

  def create
    type = favorite_params[:type]
    _id = favorite_params[:id]
    begin
      obj = FavoritesService.get_object(type, _id)
      result = FavoritesService.add(current_user, obj)
      if result
        if request.xhr?
          render json: {
                   message: 'Added a favorite',
                   favorite: result.to_json
                 } and return
        else
          msg = "#{obj.get_name(true)} has been added to your favorites."
          if obj.is_a? ArtPiece
            redirect_to art_piece_path(obj), notice: msg
          else
            redirect_to obj, notice: msg
          end
          return
        end
      end
      redirect_to obj, notice: msg
    rescue InvalidFavoriteTypeError, NameError
      render_not_found({message: "You can't favorite that type of object" })
    end
  end

  def destroy
    begin
      fav = Favorite.find(params[:id])
      obj = fav.to_obj
      fav.destroy
      if request.xhr?
        render json: {message: 'Removed a favorite'}
        return
      else
        flash[:notice] = "#{obj.get_name true} has been removed from your favorites.".html_safe
        redirect_to(request.referrer || obj)
      end
    rescue InvalidFavoriteTypeError => ex
      render_not_found({message: ex.message })
    end
  end

  def favorite_params
    params.require(:favorite).permit(:type, :id)
  end
end
