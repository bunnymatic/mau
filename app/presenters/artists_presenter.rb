# This presenter fetches a list of artists
# and makes them easily accessible as ArtistPresenter objects
class ArtistsPresenter < ViewPresenter
  attr_reader :os_only

  def initialize(os_only: false, sort_by_name: true)
    super()
    @os_only = !!os_only
    @sort_by_name = sort_by_name
  end

  def artists
    return @artists if @artists
    return Artist.none if os_only && !OpenStudiosEvent.current

    artists_list =
      begin
        if os_only
          OpenStudiosEvent.current.artists.active.includes(:open_studios_participants, :art_pieces)
        else
          Artist.active.includes(:studio, :artist_info, :art_pieces, :open_studios_events)
        end
      end
    artists_list = artists_list.sort_by(&:sortable_name) if @sort_by_name
    @artists = artists_list.map { |artist| ArtistPresenter.new(artist) }
  end
end
