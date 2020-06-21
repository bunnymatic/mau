# frozen_string_literal: true

# This presenter fetches a list of artists
# and makes them easily accessible as ArtistPresenter objects
class ArtistsPresenter < ViewPresenter
  attr_reader :os_only

  def initialize(os_only = nil)
    @os_only = !!os_only
  end

  def artists
    @artists ||=
      begin
        base_artists = Artist.active.includes(:studio, :artist_info, :art_pieces, :open_studios_events)
        if os_only
          base_artists.in_the_mission.select(&:doing_open_studios?)
        else
          base_artists
        end.sort_by(&:sortable_name)
      end.map { |artist| ArtistPresenter.new(artist) }
  end
end
