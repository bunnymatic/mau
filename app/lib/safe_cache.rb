# frozen_string_literal: true
class SafeCache
  def self.read(k)
    Rails.cache.read(k)
  rescue Dalli::RingError => mce
    Rails.logger.warn('Memcache (read) appears to be dead or unavailable')
    nil
  end

  def self.write(*opts)
    Rails.cache.write(*opts)
  rescue Dalli::RingError => mce
    Rails.logger.warn('Memcache (write) appears to be dead or unavailable')
    false
  end

  def self.delete(k)
    Rails.cache.delete(k)
  rescue Dalli::RingError => mce
    Rails.logger.warn('Memcache (delete) appears to be dead or unavailable')
    nil
  end
end
