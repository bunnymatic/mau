# == Schema Information
#
# Table name: media
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Medium < ActiveRecord::Base
  has_many :art_pieces

  #default_scope order('name')
  include TagMediaMixin

  validates :name, :presence => true, :length => {:within => (2..244)}

  CACHE_KEY = 'medfreq'
  CACHE_EXPIRY = Conf.cache_expiry["media_frequency"] || 20

  def self.alpha
    order(:name)
  end

  def self.flush_cache
    SafeCache.delete(CACHE_KEY + true.to_s)
    SafeCache.delete(CACHE_KEY + false.to_s)
  end

  def self.frequency(_normalize=false)
    cache_key = CACHE_KEY + _normalize.to_s
    freq = SafeCache.read(cache_key)
    if freq
      logger.debug('read medium frequency from cache')
      return freq
    end
    # if normalize = true, scale counts from 1.0
    meds = get_media_usage

    # compute max/min ct
    maxct = meds.map{|m| m['ct'].to_i}.max

    if !maxct || maxct <=0
      maxct = 1.0
    end

    # normalize frequency to 1
    normalize(meds, 'ct', maxct) if _normalize

    SafeCache.write(cache_key, meds, :expires_in => CACHE_EXPIRY)
    meds
  end

  def self.by_name
    order(:name)
  end

  private

  class << self
    def get_media_usage
      dbr = connection.execute("/* hand generated sql */  select medium_id medium, count(*) ct"+
                               " from art_pieces where medium_id <> 0 group by medium_id;")
      meds = dbr.map{|row| Hash[['medium','ct'].zip(row)] }
      other = self.where(["id not in (?)", meds.map { |m| m['medium'] } ])
      meds += other.map { |m| Hash[["medium", 'ct'].zip([m.id,0])]}
    end

    def normalize(arr, fld, maxct)
      arr.each do |m|
        m[fld] = m[fld].to_f / maxct.to_f
      end
    end
  end

end
