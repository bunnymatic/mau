class CacheKeyService
  REPRESENTATIVE_ART_CACHE_KEY = 'representative_art'.freeze

  def self.representative_art(artist)
    [REPRESENTATIVE_ART_CACHE_KEY, artist.id].join
  end
end
