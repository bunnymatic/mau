# frozen_string_literal: true

class ArtistsPagination < Pagination
  def previous_link
    url_helpers.artists_path(p: previous_page)
  end

  def next_link
    url_helpers.artists_path(p: next_page)
  end

  def last_link
    url_helpers.artists_path(p: last_page)
  end

  def first_link
    url_helpers.artists_path(p: first_page)
  end
end
