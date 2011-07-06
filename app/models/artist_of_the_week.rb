class ArtistOfTheWeek
  # memcache stored artist of the week
  @@CACHE_KEY = 'artist_of_the_week'

  def self.put(artist_id)
    cacheout = Rails.cache.read(@@CACHE_KEY)
    artists = cacheout ? JSON.parse(cacheout) : []
  end

  def self.get(artist_id)

  end

end
