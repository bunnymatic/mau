module Admin
  class FavoritesController < ::BaseAdminController
    before_action :admin_required
    def index
      @favorites = AdminFavoritesPresenter.new(Favorite.all.includes(:owner, :favoritable))
    end
  end
end
