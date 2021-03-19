# This presenter fetches a list of artists
# and makes them easily accessible as ArtistPresenter objects
class ArtistsPresenter < ViewPresenter
  attr_reader :os_only

  def initialize(os_only = nil)
    super()
    @os_only = !!os_only
  end

  def artists
    return @artists if @artists
    return Artist.none if os_only && !OpenStudiosEvent.current

    artists_list =
      begin
        if os_only
          OpenStudiosEvent.current.artists.includes(:open_studios_participants)&.active
        else
          Artist.active.includes(:studio, :artist_info, :art_pieces, :open_studios_events)
        end
      end
    @artists = (artists_list).sort_by(&:sortable_name).map { |artist| ArtistPresenter.new(artist) }
  end
end
