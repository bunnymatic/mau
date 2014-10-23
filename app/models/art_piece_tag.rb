# == Schema Information
#
# Table name: art_piece_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require_relative 'concerns/tag_media_mixin'

class ArtPieceTag < ActiveRecord::Base
  include TagMediaMixin

  has_many :art_pieces_tags
  has_many :art_pieces, :through => :art_pieces_tags

  validates :name, :presence => true, :length => { :within => 3..25 }

  scope :alpha, -> { order('name') }

  # class level constants
  MAX_SHOW_TAGS = 80
  CACHE_EXPIRY = Conf.cache_expiry['tag_frequency'] || 300

  def self.cache_key(norm=false)
    [:tagfreq, norm]
  end

  def self.frequency(_normalize=true)
    ckey = cache_key(_normalize)
    freq = SafeCache.read(ckey)
    if freq
      logger.debug('read tag frequency from cache')
      return freq
    end
    tags = get_tag_usage
    tags = normalize(tags, 'ct') if _normalize

    SafeCache.write(ckey, tags[0..MAX_SHOW_TAGS], :expires_in => CACHE_EXPIRY)
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

  end

end
