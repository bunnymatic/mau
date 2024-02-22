class MediumPagination < Pagination
  def initialize(art_pieces, current_medium, current_page, per_page = nil)
    @current_medium = current_medium
    super(art_pieces,
          current_page,
          per_page || Conf.pagination['media']['per_page'],
          next_label: '>',
          previous_label: '<')
  end

  def page_link(page)
    url_helpers.medium_path(@current_medium, p: page)
  end

  def previous_link
    url_helpers.medium_path(@current_medium, p: previous_page)
  end

  def next_link
    url_helpers.medium_path(@current_medium, p: next_page)
  end
end
