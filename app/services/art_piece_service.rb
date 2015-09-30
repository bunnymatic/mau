class ArtPieceService

  NEW_ART_CACHE_KEY = 'newart'
  NEW_ART_CACHE_EXPIRY = Conf.cache_expiry['new_art'].to_i

  def self.clear_cache
    SafeCache.delete(NEW_ART_CACHE_KEY)
  end

  def self.get_new_art(num_pieces=12)
    cache_key = NEW_ART_CACHE_KEY
    new_art = SafeCache.read(cache_key)
    unless new_art.present?
      new_art = ArtPiece.joins(:artist).where({users: {state: 'active'}}).limit(num_pieces).order('created_at desc').all
      SafeCache.write(cache_key, new_art, :expires_in => NEW_ART_CACHE_EXPIRY)
    end
    new_art || []
  end

end
