class FavoritesController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'

  def index
    @favorites = AdminFavoritesPresenter.new(Favorite.all)
  end
end
