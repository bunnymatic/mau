# frozen_string_literal: true

class MediumPagination < Pagination
  include ArtistOrPiece

  PER_PAGE = 24

  def initialize(art_pieces, current_medium, current_page, mode_string = 'p', per_page = nil)
    @current_medium = current_medium
    @mode_string = mode_string
    super art_pieces, current_page, per_page || PER_PAGE, next_label: '>', previous_label: '<'
  end

  def page_link(page)
    url_helpers.medium_path(@current_medium, page_args.merge(p: page))
  end

  def previous_link
    url_helpers.medium_path(@current_medium, page_args.merge(p: previous_page))
  end

  def next_link
    url_helpers.medium_path(@current_medium, page_args.merge(p: next_page))
  end
end
