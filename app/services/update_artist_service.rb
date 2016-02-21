class UpdateArtistService

  def initialize(artist, params)
    @artist = artist
    @params = params
  end

  def update
    if @params[:artist_info_attributes]
      @params[:artist_info_attributes][:open_studios_participation] = @artist.artist_info.open_studios_participation
    end

    @artist.update(@params)
  end

end
