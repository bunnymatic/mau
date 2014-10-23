# == Schema Information
#
# Table name: media
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require_relative 'concerns/tag_media_mixin'

class Medium < ActiveRecord::Base
  has_many :art_pieces

  #default_scope order('name')
  include TagMediaMixin

  validates :name, :presence => true, :length => {:within => (2..244)}

  CACHE_EXPIRY = Conf.cache_expiry["media_frequency"] || 20

  scope :alpha, -> { order(:name) }

  def self.cache_key(norm=false)
    [:medfreq, norm]
  end

  def self.frequency(_normalize=false)
    ckey = cache_key(_normalize)
    freq = SafeCache.read(ckey)
    if freq
      logger.debug('read medium frequency from cache')
      return freq
    end
    # if normalize = true, scale counts from 1.0
    meds = get_media_usage
    meds = normalize(meds, 'ct') if _normalize

    SafeCache.write(ckey, meds, :expires_in => CACHE_EXPIRY)
    meds
  end

  def self.by_name
    order(:name)
  end

  private

  class << self
    def get_media_usage
      dbr = ArtPiece.joins(:artist).where("users.state" => "active").select('medium_id').
        group('medium_id').count
      meds = dbr.select{|k,v| k}.map{|_id, ct| { "medium" => _id, "ct" => ct }}
      other = self.where(["id not in (?)", meds.map { |m| m['medium'] } ])
      meds += other.map { |m| Hash[["medium", 'ct'].zip([m.id,0])]}
    end

  end

end
