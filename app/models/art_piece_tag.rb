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

  scope :alpha, -> { order('name') }

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
    maxct = ((tags.map{|m| m['ct'].to_i}.max) || 1).to_i

    normalize(tags, 'ct', maxct) if _normalize
    SafeCache.write(CACHE_KEY, tags[0..MAX_SHOW_TAGS], :expires_in => CACHE_EXPIRY)
    tags[0..MAX_SHOW_TAGS]
  end

  def self.keyed_frequency
    # return frequency of tag usage keyed by tag id
    tags = get_tag_usage
    Hash[tags.map{|row| [row['tag'], row['ct']]}]
  end

  private
  class << self
    private
    def get_tag_usage
      dbr = ArtPieceTag.joins(:art_pieces_tags).
        where("art_pieces_tags.art_piece_id" => ArtPiece.select('art_pieces.id').
              joins(:artist).
              where("users.state" => "active")).
        group('art_piece_tags.id').count
      dbr.map{|_id, ct| { "tag" => _id, "ct" => ct }}.sort_by{|entry| -entry['ct']}
    end

    def normalize(arr, fld, maxct)
      arr.each do |m|
        m[fld] = m[fld].to_f / maxct.to_f
      end
    end
  end

end
