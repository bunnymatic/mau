class MediumPagination < Pagination

  def initialize(view_context, art_pieces, current_medium, current_page, page_args = {}, per_page = 12)
    @view_context = view_context
    @current_medium = current_medium
    @page_args = page_args
    super view_context, art_pieces, current_page, per_page
  end

  def previous_link
    @view_context.medium_path(@current_medium, @page_args.merge(:p => previous_page))
  end

  def next_link
    @view_context.medium_path(@current_medium, @page_args.merge(:p => next_page))
  end

end
