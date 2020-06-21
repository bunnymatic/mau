# frozen_string_literal: true

class TagCloudPresenter < ViewPresenter
  include Enumerable

  MAX_SHOW_TAGS = 40

  def initialize(selected)
    @all_tags = ArtPieceTagService.tags_sorted_by_frequency
    @selected = selected
  end

  def current_tag?(tag)
    @selected == tag
  end

  def tag_path(tag)
    url_helpers.art_piece_tag_path(tag)
  end

  def tags
    @all_tags.limit(MAX_SHOW_TAGS)
  end

  def each(&block)
    tags.each(&block)
  end
end
