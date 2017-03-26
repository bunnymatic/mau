# frozen_string_literal: true
class SuspendArtistService
  def initialize(artist)
    @artist = artist
  end

  def suspend!
    @artist.suspend!
    remove_from_search_index
  end

  private

  def remove_from_search_index
    Search::Indexer.remove(@artist)
  end
end
