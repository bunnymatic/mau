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
      redirect_to edit_artist_path(current_user, anchor: "events")
    else
      store_location(my_profile_artists_path(current_user))
      redirect_to sign_in_path
    end
  end
end
