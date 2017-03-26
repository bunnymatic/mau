# frozen_string_literal: true
class TagConverter
  def initialize(tagstr)
    @tag_string = tagstr
  end

  def tag_names
    @tag_names ||= @tag_string.split(',').map(&:strip).compact.uniq
  end

  def convert
    # split up @tag_string into array of tags
    return [] unless @tag_string.present?

    found_tags = ArtPieceTag.where(name: tag_names)
    new_tags =
      begin
        (tag_names - found_tags.map(&:name)).map do |new_tag|
          ArtPieceTag.create(name: new_tag)
        end
      end
    new_tags + found_tags
  end
end
