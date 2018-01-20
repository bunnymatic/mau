# frozen_string_literal: true

class CacheKeyService
  REPRESENTATIVE_ART_CACHE_KEY = 'representative_art'

  def self.representative_art(artist)
    [REPRESENTATIVE_ART_CACHE_KEY, artist.id].join('')
  end
end
