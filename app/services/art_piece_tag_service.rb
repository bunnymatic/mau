# frozen_string_literal: true
class ArtPieceTagService
  class TagWithFrequency
    FIELDS = [:tag, :frequency].freeze
    attr_accessor(*FIELDS)
    def initialize(tag, count)
      @tag = tag
      @frequency = count.try(:to_f)
    end

    def [](key)
      raise NoMethodError, "#{key} does not exist as a method on #{inspect}" unless FIELDS.include?(key.to_sym)
      send(key)
    end

    def []=(key, val)
      raise NoMethodError, "#{key} does not exist as a method on #{inspect}" unless FIELDS.include?(key.to_sym)
      send("#{key}=", val)
    end
  end

  include TagMediaMixin

  # class level constants
  MAX_SHOW_TAGS = 40
  CACHE_EXPIRY = Conf.cache_expiry['tag_frequency'] || 300

  def self.cache_key(norm = false)
    [:tagfreq, norm]
  end

  def self.delete_unused_tags
    unused = tags_sorted_by_frequency.select { |tf| tf.frequency.to_f <= 0 }.map { |t| t.tag.slug }
    ArtPieceTag.where(slug: unused).destroy_all
    flush_cache
  end

  def self.tags_sorted_by_frequency
    freq = keyed_frequency
    ArtPieceTag.all.map do |tag|
      TagWithFrequency.new(tag, freq[tag.slug].to_f)
    end.sort_by { |tf| -tf.frequency.to_f }
  end

  def self.destroy(tags)
    tags = [tags].flatten.compact
    return unless tags.any?
    ActiveRecord::Base.transaction do
      ArtPiecesTag.where(art_piece_tag_id: tags.map(&:id)).delete_all
      ArtPieceTag.where(id: tags.map(&:id)).destroy_all
      flush_cache
    end
  end

  def self.most_popular_tag
    popular_tag = frequency.sort_by { |tf| [-tf.frequency, -tf.tag] }.first
    ArtPieceTag.find_by(slug: popular_tag.tag) if popular_tag
  end

  def self.frequency(normalized = true)
    ckey = cache_key(normalized)
    freq = SafeCache.read(ckey)
    return freq if freq
    tags = compute_tag_usage
    tags = normalize(tags, 'frequency') if normalized

    SafeCache.write(ckey, tags[0..MAX_SHOW_TAGS], expires_in: CACHE_EXPIRY)
    tags[0..MAX_SHOW_TAGS]
  end

  class << self
    private

    def keyed_frequency
      # return frequency of tag usage keyed by tag id
      compute_tag_usage.each_with_object({}) do |record, memo|
        memo[record.tag] = record.frequency
      end
    end

    def compute_tag_usage
      art_piece_ids_query = ArtPiece
                            .select('art_pieces.id')
                            .joins(:artist)
                            .where('users.state' => 'active')
      dbr = ArtPieceTag.joins(:art_pieces_tags)
                       .where('art_pieces_tags.art_piece_id' => art_piece_ids_query)
                       .group('art_piece_tags.slug').count
      dbr.map { |id, ct| TagWithFrequency.new(id, ct) }.sort_by { |tf| -tf.frequency }
    end
  end
end
