module OpenStudiosSubdomain
  class MainController < BaseOpenStudiosController
    def index
      @gallery = OpenStudiosCatalogArtists.new
      @presenter = OpenStudiosCatalogPresenter.new(current_user)
    end
  end
end
