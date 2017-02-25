# frozen_string_literal: true
class SafeCache
  def self.read(k)
    begin
      Rails.cache.read(k)
    rescue Dalli::RingError => mce
      Rails.logger.warn('Memcache (read) appears to be dead or unavailable')
      nil
    end
  end

  def self.write(*opts)
    begin
      Rails.cache.write(*opts)
    rescue Dalli::RingError => mce
      Rails.logger.warn('Memcache (write) appears to be dead or unavailable')
      false
    end
  end

  def self.delete(k)
    begin
      Rails.cache.delete(k)
    rescue Dalli::RingError => mce
      Rails.logger.warn('Memcache (delete) appears to be dead or unavailable')
      nil
    end
  end
end
