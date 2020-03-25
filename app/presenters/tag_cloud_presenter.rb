# frozen_string_literal: true

class TagCloudPresenter < ViewPresenter
  include Enumerable
  include TagsHelper

  attr_reader :frequency, :current_tag, :mode

  def initialize(model, tag, mode)
    @model = model
    @frequency = ArtPieceTagService.frequency(true)
    @current_tag = tag
    @mode = mode
  end

  def tags
    @tags ||=
      begin
        ArtPieceTag.where(slug: frequency.map(&:tag))
      end
  end

  def tags_lut
    @tags_lut ||=
      begin
        tags.index_by(&:slug)
      end
  end

  def find_tag(slug)
    tags_lut[slug]
  end

  def current_tag?(tag)
    current_tag == tag
  end

  def tag_path(tag)
    url_helpers.art_piece_tag_path(tag, m: mode)
  end

  def tags_for_display
    @tags_for_display ||=
      begin
        frequency.map do |entry|
          tag = find_tag(entry.tag)
          next unless tag

          tag
        end.compact
      end
  end

  def each(&block)
    tags_for_display.each(&block)
  end
end
