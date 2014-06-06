module Admin
  class FavoritesController < BaseAdminController
    before_filter :admin_required
    def index
      @favorites = AdminFavoritesPresenter.new(Favorite.all)
    end
  end
end
