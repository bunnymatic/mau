class MediaPresenter

  attr_reader :medium
  def initialize(view_context, medium, page = nil, mode = nil, per_page = nil)
    @view_context = view_context
    @medium = medium
    @page = (page || 0).to_i
    @mode_string = mode || 'p'
    @per_page ||= 20
  end

  def by_artist? 
    (@mode_string != 'p')
  end

  def by_art_piece?
    (!by_artist?)
  end

  def art_pieces
    @art_pieces ||= paginator.items
  end

  def all_art_pieces
    @all_art_pieces ||=
      begin
        if by_art_piece?
          raw_art_pieces
        else
          art_pieces_by_artist
        end
      end
  end

  def art_pieces_by_artist
    tmps = {}
    raw_art_pieces.each do |pc|
      tmps[pc.artist_id] = pc unless tmps.has_key? pc.artist_id
    end
    tmps.values.sort_by { |p| p.updated_at }.reverse
  end

  def mode_opts
    {:m => @mode_string}
  end

  def paginator
    @paginator ||= MediumPagination.new(@view_context, all_art_pieces, @medium, @page, mode_opts, @per_page)
  end

  private
  def raw_art_pieces
    @raw_art_pieces ||= @medium.art_pieces.order('updated_at')
  end



end
