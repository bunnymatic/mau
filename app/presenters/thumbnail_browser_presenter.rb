class ThumbnailBrowserPresenter

  attr_reader :next_img, :prev_img, :current_index

  def initialize(view_context, artist, current_piece)
    @view_context = view_context
    @artist = artist
    @current_piece = current_piece
    thumbs # need this to init current index etc
  end

  def pieces
    @art_pieces ||= @artist.art_pieces.map{|ap| ArtPiecePresenter.new(ap) }
  end

  def num_pieces
    @num_pieces ||= pieces.count
  end

  def has_thumbs?
    thumbs.count > 0
  end
  
  def is_current_piece(piece)
    piece == @current_piece
  end

  def row_class
    num_rows = (thumbs.length.to_f / 4.0).ceil.to_i
    "rows#{num_rows}"
  end

  def thumbs
    @thumbs ||= pieces.map.with_index do |item, idx|
      item_id = item.send(:id)
      item_path = item.get_path('thumb')
      style = "background-image:url(#{item_path});"
      thumb = {
        :path => item_path,
        :clz => 'tiny-thumb',
        :id => item_id,
        :link => @view_context.art_piece_path(item),
        :background_style => style
      }
      if item_id == @current_piece.id
        set_current_piece(idx)
        thumb[:clz] << ' selected'
      end
      OpenStruct.new(thumb)
    end
  end

  def thumbs_json
    @json ||= thumbs.map(&:marshal_dump).to_json.html_safe
  end

  private
  def set_current_piece(idx)
    @current_index = idx
    nxt = (idx + 1) % num_pieces
    prv = (idx - 1) % num_pieces
    @next_img = pieces[nxt].id
    @prev_img = pieces[prv].id
  end
end
