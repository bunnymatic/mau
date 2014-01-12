class MediumPagination < Pagination

  include ArtistOrPiece

  def initialize(view_context, art_pieces, current_medium, current_page, mode_string = 'p', per_page = 12)
    @view_context = view_context
    @current_medium = current_medium
    @mode_string = mode_string
    super view_context, art_pieces, current_page, per_page
  end


  def previous_link
    @view_context.medium_path(@current_medium, page_args.merge(:p => previous_page))
  end

  def next_link
    @view_context.medium_path(@current_medium, page_args.merge(:p => next_page))
  end

end
