class TagConverter
  def initialize(tagstr)
    @tag_string = tagstr
  end

  def tag_names
    @tag_names ||= @tag_string.split(',').map(&:strip).compact.uniq
  end

  def convert
    # split up @tag_string into array of tags
    return [] if @tag_string.blank?

    found_tags = ArtPieceTag.where(name: tag_names)
    new_tags =
      (tag_names - found_tags.map(&:name)).map do |new_tag|
        ArtPieceTag.create(name: new_tag)
      end

    new_tags + found_tags
  end
end
