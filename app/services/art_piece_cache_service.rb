class ArtPieceCacheService
  NEW_ART_CACHE_KEY = 'newart'.freeze
  NEW_ART_CACHE_EXPIRY = Conf.cache_expiry['new_art'].to_i

  def self.clear
    SafeCache.delete(NEW_ART_CACHE_KEY)
  end
end
