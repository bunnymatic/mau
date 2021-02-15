class OpenStudiosController < ApplicationController
  def index
    @page_title = PageInfoService.title('Open Studios')
    @os_only = true
    cur_page = (params[:p] || 0).to_i

    @gallery = ArtistsGallery.new(true, nil, nil, cur_page)
    if request.xhr?
      render partial: '/artists/artist_list', locals: { gallery: @gallery }
    else
      @presenter = OpenStudiosPresenter.new
      @map_info = ArtistsMap.new(true)
      render
    end
  end

  def show
    (redirect_to '/error' and return) unless FeatureFlags.virtual_open_studios?

    artist = Artist.active.joins(:open_studios_events).friendly.find(params[:id])
    @artist = ArtistPresenter.new(artist) if artist&.doing_open_studios?
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "It doesn't look like that artist is doing open studios" unless artist
    redirect_to open_studios_path
  end

  def register
    if current_user
      redirect_to register_for_current_open_studios_artists_path
    else
      store_location(register_for_current_open_studios_artists_path)
      redirect_to sign_in_path
    end
  end
end
