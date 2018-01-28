# frozen_string_literal: true

class OpenStudiosController < ApplicationController
  def show
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

  def register
    if current_user
      redirect_to register_for_current_open_studios_artists_path
    else
      store_location(register_for_current_open_studios_artists_path)
      redirect_to sign_in_path
    end
  end
end
