class SafeCache 

  def self.read(k)
    begin
      Rails.cache.read(k)
    rescue Dalli::RingError => mce
      logger.warning("Memcache (read) appears to be dead or unavailable")
      nil
    end
  end

  def self.write(*opts)
    begin
      Rails.cache.write(*opts)
    rescue Dalli::RingError => mce
      logger.warning("Memcache (read) appears to be dead or unavailable")
      false
    end
  end

  def self.delete(k)
    begin
      Rails.cache.delete(k)
    rescue Dalli::RingError => mce
      logger.warning("Memcache (read) appears to be dead or unavailable")
      nil
    end
  end

end
