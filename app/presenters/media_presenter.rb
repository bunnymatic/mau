class MediaPresenter

  include ArtistOrPiece

  attr_reader :medium

  def initialize(view_context, medium, page = nil, mode = nil, per_page = nil)
    @view_context = view_context
    @medium = medium
    @page = (page || 0).to_i
    @mode_string = mode || 'p'
    @per_page = per_page || 20
  end

  def art_pieces
    @art_pieces ||= paginator.items.map{|a| ArtPiecePresenter.new(@view_context,a)}
  end

  def all_art_pieces
    @all_art_pieces ||=
      begin
        if by_artists?
          art_pieces_by_artist
        else
          raw_art_pieces
        end
      end
  end

  def art_pieces_by_artist
    @art_pieces_by_artist ||=
      begin
        {}.tap do |bucket|
          raw_art_pieces.each do |piece|
            bucket[piece.artist_id] = piece unless bucket.has_key? piece.artist_id
          end
        end.values.sort_by { |p| p.updated_at }.reverse
      end
  end

  def paginator
    @paginator ||= MediumPagination.new(@view_context, all_art_pieces, @medium, @page, @mode_string, @per_page)
  end

  private
  def raw_art_pieces
    @raw_art_pieces ||= @medium.art_pieces.order('updated_at').reverse
  end

end
