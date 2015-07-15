class OpenStudiosController < ApplicationController

  def show
    @page_title = "Mission Artists United: Spring Open Studios"
    
    @presenter = OpenStudiosPresenter.new
    @map_info = ArtistsMap.new(true)
    @gallery = ArtistsGallery.new(true, nil, 0)

    binding.pry
  end

end
