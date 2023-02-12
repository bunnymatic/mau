module OpenStudiosSubdomain
  class MainController < BaseOpenStudiosController
    def index
      render 'no_scheduled_open_studios' and return unless @open_studios_active

      @gallery = OpenStudiosCatalogArtists.new
      @presenter = OpenStudiosCatalogPresenter.new(current_user)
    end
  end
end
