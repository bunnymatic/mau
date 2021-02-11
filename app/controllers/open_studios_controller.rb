# frozen_string_literal: true

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
    artist = active_artist_from_params
    @artist = ArtistPresenter.new(artist) if artist&.doing_open_studios?
  end

  def register
    if current_user
      redirect_to register_for_current_open_studios_artists_path
    else
      store_location(register_for_current_open_studios_artists_path)
      redirect_to sign_in_path
    end
  end

  private

  def active_artist_from_params
    artist = begin
      Artist.active.joins(:open_studios_events).friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      nil
    end
    flash.now[:error] = "We couldn't find who you were looking for" unless artist
    artist
  end
end
