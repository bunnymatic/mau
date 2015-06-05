class FavoritesController < ApplicationController

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

  def remove_favorite
    # POST
    type = params[:fav_type]
    _id = params[:fav_id]
    if Favorite::FAVORITABLE_TYPES.include? type
      obj = type.constantize.find(_id)
      if obj
        current_user.remove_favorite(obj)
      end
      if request.xhr?
        render :json => {:message => 'Removed a favorite'}
        return
      else
        flash[:notice] = "#{obj.get_name true} has been removed from your favorites."
        redirect_to(request.referrer || obj)
      end
    else
      render_not_found({:message => "You can't unfavorite that type of object" })
    end
  end
  

end
