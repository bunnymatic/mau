class Medium < ActiveRecord::Base
  belongs_to :art_piece

  include TagMediaMixin

  @@CACHE_KEY = 'medfreq'
  @@CACHE_EXPIRY = Conf.cache_expiry["media_frequency"] || 20

  def self.flush_cache
    Rails.cache.delete(@@CACHE_KEY + true.to_s)
    Rails.cache.delete(@@CACHE_KEY + false.to_s)
  end

  def self.frequency(normalize=false)
    cache_key = @@CACHE_KEY + normalize.to_s
    freq = Rails.cache.read(cache_key)
    if freq
      logger.debug('read medium frequency from cache')
      return freq
    end
    # if normalize = true, scale counts from 1.0
    meds = []
    dbr = connection.execute("/* hand generated sql */  select medium_id medium, count(*) ct from art_pieces where medium_id <> 0 group by medium_id;")
    fields = dbr.fields
    dbr.each do |row|
      rowhash = {}
      fields.each_with_index do |f, idx|
        rowhash[f] = row[idx]
      end
      meds << rowhash
    end
    other = self.find(:all,:conditions => ["id not in (?)", meds.map { |m| m['medium'] } ])
    other.map { |m| meds << Hash["medium" => m.id, "ct" => 0 ] }
    
    # compute max/min ct
    maxct = nil
    meds.each do |m|
      if maxct == nil || maxct < m['ct'].to_i
        maxct = m['ct'].to_i
      end
    end  
    # normalize frequency to 1
    if maxct <= 0
      maxct = 1.0
    end
    if normalize
      meds.each do |m|
        m['ct'] = m['ct'].to_f / maxct.to_f
      end
    end
    Rails.cache.write(cache_key, meds, :expires_in => @@CACHE_EXPIRY)
    meds
  end

end
