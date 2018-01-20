# frozen_string_literal: true

class ArtPieceTagPagination < Pagination
  include ArtistOrPiece

  def initialize(art_pieces, current_tag, current_page, mode_string = 'p', per_page = 12)
    @mode_string = mode_string
    @current_tag = current_tag
    super art_pieces, current_page, per_page, next_label: '>', previous_label: '<'
  end

  def page_link(page)
    url_helpers.art_piece_tag_path(@current_tag, page_args.merge(p: page))
  end

  def previous_link
    url_helpers.art_piece_tag_path(@current_tag, page_args.merge(p: previous_page))
  end

  def next_link
    url_helpers.art_piece_tag_path(@current_tag, page_args.merge(p: next_page))
  end
end
