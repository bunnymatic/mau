module OpenStudiosSubdomain
  class MainController < BaseOpenStudiosController
    def index
      cur_page = (params[:p] || 0).to_i
      @os_only = true
      @gallery = ArtistsGallery.new(os_only: true, current_page: cur_page, per_page: 40)
      if request.xhr?
        render partial: '/artists/artist_list', locals: { gallery: @gallery, in_catalog: true }
      else
        @presenter = OpenStudiosCatalogPresenter.new(current_user)
        render
      end
    end
  end
end
