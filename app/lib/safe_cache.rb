class SafeCache
  def self.read(key)
    Rails.cache.read(key)
  rescue Dalli::RingError
    Rails.logger.warn('Memcache (read) appears to be dead or unavailable')
    nil
  end

  def self.write(*opts)
    Rails.cache.write(*opts)
  rescue Dalli::RingError
    Rails.logger.warn('Memcache (write) appears to be dead or unavailable')
    false
  end

  def self.delete(key)
    Rails.cache.delete(key)
  rescue Dalli::RingError
    Rails.logger.warn('Memcache (delete) appears to be dead or unavailable')
    nil
  end
end
