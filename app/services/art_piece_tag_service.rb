class ArtPieceTagService
  include TagMediaMixin

  def self.delete_unused_tags
    unused_tags.destroy_all
  end

  def self.tags_sorted_by_frequency
    ArtPieceTag
      .joins(:art_pieces_tags)
      .select('art_piece_tags.*', 'count(*) frequency')
      .group('id')
      .order('frequency desc')
  end

  def self.unused_tags
    tags_in_use = ArtPiecesTag.select(:art_piece_tag_id).distinct(:art_piece_tag_id).pluck(:art_piece_tag_id)
    ArtPieceTag.where.not(id: tags_in_use).select('art_piece_tags.*', '0 as frequency')
  end

  def self.destroy(tags)
    tags = [tags].flatten.compact
    return unless tags.any?

    ActiveRecord::Base.transaction do
      ArtPiecesTag.where(art_piece_tag_id: tags.map(&:id)).delete_all
      ArtPieceTag.where(id: tags.map(&:id)).destroy_all
    end
  end

  def self.most_popular_tag
    tags_sorted_by_frequency.first
  end
end
