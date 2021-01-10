# frozen_string_literal: true

class FavoritesController < ApplicationController
  before_action :user_required, only: %i[create destroy]
  before_action :user_must_be_you, only: %i[create destroy]

  def index
    @user = begin
      User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      nil
    end
    if @user.nil? || !@user.active?
      flash[:error] = 'The account you were looking for was not found.'
      redirect_back_or_default(artists_path)
      return
    end

    @favorites = FavoritesCollectionPresenter.new @user, current_user
  end

  def create
    type = favorite_params[:type]
    id = favorite_params[:id]
    begin
      obj = FavoritesService.get_object(type, id)
      result = FavoritesService.add(current_user, obj)
      msg = "#{obj.get_name(escape: true)} has been added to your favorites."
      msg = "We love you too, but you can't favorite yourself." unless result
      render(json: { message: msg }) && return
    rescue InvalidFavoriteTypeError, NameError
      render_not_found(message: "You can't favorite that type of object") && (return)
    end
    head(404)
  end

  def destroy
    fav = Favorite.find(params[:id])
    obj = fav.favoritable
    fav.destroy
    if request.xhr?
      render json: { message: 'Removed a favorite' }
      nil
    else
      flash[:notice] = "#{obj.get_name(escape: true)} has been removed from your favorites."
      redirect_to(request.referer || root_path)
    end
  rescue InvalidFavoriteTypeError => e
    render_not_found(message: e.message)
  end

  def favorite_params
    params.require(:favorite).permit(:type, :id)
  end
end
