class ArtistsPagination < Pagination

  def initialize(view_context, art_pieces, current_page, per_page)
    @view_context = view_context
    super view_context, art_pieces, current_page, per_page
  end

  def previous_link
    index_path(:p => previous_page)
  end

  def next_link
    index_path(:p => next_page)
  end

  def last_link
    index_path(:p => last_page)
  end

  def first_link
    index_path(:p => first_page)
  end

  private
  def index_path(opts)
    @view_context.artists_path(opts)
  end

end
