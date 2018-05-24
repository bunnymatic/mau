# frozen_string_literal: true

class Medium < ApplicationRecord
  has_many :art_pieces, dependent: :nullify, inverse_of: :medium

  # default_scope order('name')
  include TagMediaMixin

  include FriendlyId
  friendly_id :name, use: [:slugged]

  validates :name, presence: true, length: { within: (2..244) }

  CACHE_EXPIRY = Conf.cache_expiry['media_frequency'] || 20

  scope :alpha, -> { order(:name) }

  def hashtag
    return name.parameterize.underscore unless /^painting/i =~ name
    name.split('-').map(&:strip).reverse.join('').downcase
  end

  def self.options_for_select
    [['None', 0]] + Medium.all.map { |u| [u.name, u.id] }
  end

  def self.cache_key(norm = false)
    [:medfreq, norm]
  end

  def self.frequency(normalized = false)
    ckey = cache_key(normalized)
    freq = SafeCache.read(ckey)
    if freq
      logger.debug('read medium frequency from cache')
      return freq
    end
    # if normalize = true, scale counts from 1.0
    meds = tally_media_usage
    meds = normalize(meds, 'ct') if normalized

    SafeCache.write(ckey, meds, expires_in: CACHE_EXPIRY)
    meds
  end

  def self.by_name
    order(:name)
  end

  class << self
    private

    def tally_media_usage
      dbr = ArtPiece.joins(:artist).where('users.state' => 'active').select('medium_id')
                    .group('medium_id').count
      Medium.all.map { |medium| { 'medium' => medium.id, 'ct' => dbr[medium.id].to_i } }
    end
  end
end
