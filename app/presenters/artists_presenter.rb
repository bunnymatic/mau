# frozen_string_literal: true

# This presenter fetches a list of artists
# and makes them easily accessible as ArtistPresenter objects
class ArtistsPresenter < ViewPresenter
  PER_PAGE = 28

  attr_reader :os_only

  def initialize(os_only = nil)
    @os_only = !!os_only
  end

  def artists
    @artists ||=
      begin
        if os_only
          OpenStudiosEventService.current.artists.in_the_mission
        else
          Artist.active.includes(:studio, :artist_info, :art_pieces)
        end.sort_by(&:sortable_name)
      end.map { |artist| ArtistPresenter.new(artist) }
  end
end
