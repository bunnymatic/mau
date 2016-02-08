class ArtPieceTagService
  def self.delete_unused_tags
    unused = tags_sorted_by_frequency.select{|(tag,ct)| ct <= 0}.map{|(tag,ct)| tag.slug}
    ArtPieceTag.destroy_all(slug: unused)
    flush_cache
  end

  def self.tags_sorted_by_frequency
    all_tags = ArtPieceTag.all
    freq = ArtPieceTag.keyed_frequency
    all_tags.map do |tag|
      [tag, freq[tag.slug].to_f]
    end.select(&:first).sort_by(&:last).reverse
  end

  def self.flush_cache
    ArtPieceTag.flush_cache
  end

  def self.destroy(tags)
    tags = [tags].flatten.compact
    return unless tags.any?
    ArtPiecesTag.delete_all( art_piece_tag_id: tags.map(&:id) )
    tags.each(&:destroy)
    ArtPieceTag.flush_cache
  end
end
