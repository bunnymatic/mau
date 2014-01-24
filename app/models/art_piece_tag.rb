# == Schema Information
#
# Table name: art_piece_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ArtPieceTag < ActiveRecord::Base
  include TagMediaMixin

  has_many :art_pieces_tags
  has_many :art_pieces, :through => :art_pieces_tags

  validates :name, :presence => true, :length => { :within => 3..25 }

  # class level constants
  MAX_SHOW_TAGS = 80
  CACHE_KEY = 'tagfreq'
  CACHE_EXPIRY = Conf.cache_expiry['tag_frequency'] || 300

  def self.flush_cache
    SafeCache.delete(CACHE_KEY + true.to_s)
    SafeCache.delete(CACHE_KEY + false.to_s)
  end

  def self.frequency(_normalize=true)
    freq = SafeCache.read(CACHE_KEY + _normalize.to_s)
    if freq
      logger.debug('read tag frequency from cache')
      return freq
    end
    tags = get_tag_usage

    maxct = tags.map{|m| m['ct'].to_i}.max
    maxct = 1.0 if maxct <= 0

    normalize(tags, 'ct', maxct) if _normalize
    SafeCache.write(CACHE_KEY, tags[0..MAX_SHOW_TAGS], :expires_in => CACHE_EXPIRY)
    tags[0..MAX_SHOW_TAGS]
  end

  def self.keyed_frequency
    # return frequency of tag usage keyed by tag id
    tags = get_tag_usage
    Hash[tags.map{|row| [row['tag'], row['ct']]}]
  end


  def self.all
    logger.debug("ArtPieceTag: Fetching from db")
    super(:order => 'name')
  end


  private
  class << self
    private
    def get_tag_usage
      dbr = connection.execute("/* hand generated sql */ select art_piece_tag_id tag,count(*) ct from "+
                               "art_pieces_tags where art_piece_tag_id in (select id from art_piece_tags) and "+
                               "art_piece_id in (select id from art_pieces) "+
                               "group by art_piece_tag_id order by ct desc, tag desc;")
      dbr.map{|row| Hash[['tag','ct'].zip(row)]}
    end

    def normalize(arr, fld, maxct)
      arr.each do |m|
        m[fld] = m[fld].to_f / maxct.to_f
      end
    end
  end

end
