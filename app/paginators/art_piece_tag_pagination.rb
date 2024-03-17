class ArtPieceTagPagination < Pagination
  def initialize(art_pieces, current_tag, current_page, per_page = nil)
    @current_tag = current_tag
    super(art_pieces,
          current_page,
          per_page || Conf.pagination['tags']['per_page'],
          next_label: '>',
          previous_label: '<')
  end

  def page_link(page)
    url_helpers.art_piece_tag_path(@current_tag, p: page)
  end

  def previous_link
    url_helpers.art_piece_tag_path(@current_tag, p: previous_page)
  end

  def next_link
    url_helpers.art_piece_tag_path(@current_tag, p: next_page)
  end
end
