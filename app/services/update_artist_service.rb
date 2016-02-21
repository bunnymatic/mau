class UpdateArtistService

  def initialize(artist, params)
    @artist = artist
    @params = params
  end

  def update
    if @params[:artist_info_attributes]
      @params[:artist_info_attributes][:open_studios_participation] = @artist.artist_info.open_studios_participation
    end

    success = @artist.update(@params)
    if success
      refresh_in_search_index
    end
    success
  end

  private

  def refresh_in_search_index
    if @artist.active?
      Search::Indexer.update(@artist)
    else
      Search::Indexer.remove(@artist)
    end
  end

end
