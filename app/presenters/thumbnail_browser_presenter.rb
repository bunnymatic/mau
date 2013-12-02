class ThumbnailBrowserPresenter

  attr_reader :next_img, :prev_img, :current_index

  def initialize(view_context, artist, current_piece)
    @view_context = view_context
    @artist = artist
    @current_piece = current_piece
    thumbs # need this to init current index etc
  end

  def pieces
    @art_pieces ||= @artist.art_pieces
  end

  def has_thumbs?
    thumbs.count > 0
  end

  def row_class
    num_rows = (thumbs.length.to_f / 4.0).ceil.to_i
    "rows#{num_rows}"
  end

  def thumbs
    npieces = pieces.count
    @thumbs ||= pieces.map.with_index do |item, idx|
      item_id = item.send(:id)
      item_path = item.get_path('thumb')
      style = "background-image:url(#{item_path}); background-position: center center;"
      thumb = {
        :path => item_path,
        :clz => 'tiny-thumb',
        :id => item_id,
        :link => @view_context.art_piece_path(item),
        :background_style => style
      }
      if item_id == @current_piece.id
        @current_index = idx
        thumb[:clz] << ' tiny-thumb-sel'
        nxt = (idx + 1) % npieces
        prv = (idx - 1) % npieces
        @next_img = pieces[nxt].id
        @prev_img = pieces[prv].id
      end
      OpenStruct.new(thumb)
    end
  end

  def thumbs_json
    @json ||= thumbs.map(&:marshal_dump).to_json.html_safe
  end

end
