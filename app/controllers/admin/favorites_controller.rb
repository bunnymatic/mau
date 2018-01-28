# frozen_string_literal: true

module Admin
  class FavoritesController < ::BaseAdminController
    before_action :admin_required
    def index
      @favorites = AdminFavoritesPresenter.new(Favorite.all)
    end
  end
end
