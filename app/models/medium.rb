class Medium < ActiveRecord::Base
  belongs_to :art_piece

  after_save :flush_cache
  after_update :flush_cache
  after_destroy :flush_cache

  @@CACHE_EXPIRY = (Conf.cache_expiry['objects'] or 0)
  @@MEDIA_KEY = (Conf.cache_ns or '') + 'media'

  def self.frequency
    meds = []
    dbr = connection.execute("/* hand generated sql */  select medium_id medium, count(*) ct from art_pieces where medium_id <> 0 group by medium_id;")
    dbr.each_hash{ |row| meds << row }
    other = self.find(:all,:conditions => ["id not in (?)", meds.map { |m| m['medium'] } ])
    other.map { |m| meds << Hash["medium" => m.id, "ct" => 0 ] }
    meds
  end

  def self.all
    begin
      media = CACHE.get(@@MEDIA_KEY)
    rescue
      logger.warn("Medium: Memcache seems to be dead")
      media = nil
    end
    if ! media
      logger.debug("Medium: Fetching from db")
      media = super(:order => 'name')
      begin
        CACHE.set(@@MEDIA_KEY, media, @@CACHE_EXPIRY)
      rescue
        logger.warn("Medium: Failed to set media in cache")
      end
    else
      logger.debug("Medium: fetch from cache")
    end
    media
  end

  def safe_name
    self.name.gsub(' ', '&nbsp;')
  end

  protected
  def flush_cache
    logger.debug "Medium: Flushing cache"
    begin
      CACHE.delete(@@MEDIA_KEY)
    rescue
      logger.warn("Medium: Memcache delete failed")
    end
  end

end
