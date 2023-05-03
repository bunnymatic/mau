class SuspendArtistService
  def initialize(artist)
    @artist = artist
  end

  def suspend!
    @artist.suspend!
    remove_from_search_index
  end

  def unsuspend!
    @artist.reactivate!
    add_to_search_index
  end

  private

  def remove_from_search_index
    Search::Indexer.remove(@artist)
  end

  def add_to_search_index
    Search::Indexer.index(@artist)
  end
end
