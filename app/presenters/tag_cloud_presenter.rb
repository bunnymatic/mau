class TagCloudPresenter < ViewPresenter

  include Enumerable
  include TagsHelper

  attr_reader :frequency, :current_tag, :mode

  def initialize(model, tag, mode)
    @model = model
    @frequency = model.frequency(true)
    @current_tag = tag
    @mode = mode
  end

  def tags
    @tags ||=
      begin
        tags = frequency.map{|t| t['tag']}
        ArtPieceTag.where(id: tags)
      end
  end

  def tags_lut
    @tags_lut ||=
      begin
        Hash[tags.map{|t| [t.id, t]}]
      end
  end

  def find_tag(tag_id)
    tags_lut[tag_id]
  end

  def is_current_tag?(tag)
    current_tag == tag
  end

  def tag_path(tag)
    url_helpers.art_piece_tag_path(tag, m: mode)
  end

  def tags_for_display
    @tags_for_display ||=
      begin
        frequency.map do |entry|
          tag = find_tag(entry['tag'])
          next unless tag
          tag
        end.compact
      end
  end

  def each(&block)
    tags_for_display.each(&block)
  end
end
