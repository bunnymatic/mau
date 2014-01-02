class TagCloudPresenter

  include TagsHelper

  attr_reader :frequency, :current_tag, :mode

  def initialize(view_context, model, tag, mode)
    @view_context = view_context
    @model = model
    @frequency = model.frequency(true)
    @current_tag = tag
    @mode = mode
  end

  def tags
    @tags ||=
      begin
        tags = frequency.map{|t| t['tag']}
        ArtPieceTag.where(:id => tags)
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

  def compute_style(frequency_entry)
    ct = frequency_entry['ct'].to_f
    (fontsize, margin) = fontsize_from_frequency(ct)
    "font-size:#{fontsize}; margin: #{margin};"
  end

  def tag_path(tag)
    @view_context.art_piece_tag_path(tag, :m => mode)
  end

  def tags_for_display
    @tags_for_display ||=
      begin
        frequency.map do |entry|
          style = compute_style(entry)
          tag = find_tag(entry['tag'])
          next unless tag
          clz = "tagmatch" if is_current_tag?(tag)
          @view_context.content_tag 'span', :class => ['clouditem', clz].compact.join(' '), :style => style do
            @view_context.link_to tag.safe_name, tag_path(tag)
          end
        end
      end
  end
end
