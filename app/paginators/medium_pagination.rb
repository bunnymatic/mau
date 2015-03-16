class MediumPagination < Pagination

  include ArtistOrPiece

  def initialize(art_pieces, current_medium, current_page, mode_string = 'p', per_page = 12)
    @current_medium = current_medium
    @mode_string = mode_string
    super art_pieces, current_page, per_page, next_label: '>', previous_label: '<'
  end

  def page_link(page)
    url_helpers.medium_path(@current_medium, page_args.merge(:p => page))
  end

  def previous_link
    url_helpers.medium_path(@current_medium, page_args.merge(:p => previous_page))
  end

  def next_link
    url_helpers.medium_path(@current_medium, page_args.merge(:p => next_page))
  end

end
