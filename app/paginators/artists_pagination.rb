class ArtistsPagination < Pagination

  def initialize(view_context, art_pieces, current_page, per_page)
    @view_context = view_context
    super art_pieces, current_page, per_page
  end

  def previous_title
    @previous_title || 'previous'
  end

  def link_to_previous
    @view_context.link_to previous_label, previous_link, :title => previous_title
  end

  def link_to_next
    @view_context.link_to next_label, next_link, :title => next_title
  end

  def previous_label
    (@previous_label || '&lt;prev').html_safe
  end

  def next_title
    @next_title || 'next'
  end

  def next_label
    (@next_label || 'next&gt;').html_safe
  end

  def previous_link
    @view_context.artists_path(@current_tag, :p => previous_page)
  end

  def next_link
    @view_context.artists_path(@current_tag, :p => next_page)
  end

end
