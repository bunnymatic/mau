class ArtPieceService

  NEW_ART_CACHE_KEY = 'newart'
  NEW_ART_CACHE_EXPIRY = Conf.cache_expiry['new_art'].to_i

  def self.clear_cache
    SafeCache.delete(NEW_ART_CACHE_KEY)
  end

end
