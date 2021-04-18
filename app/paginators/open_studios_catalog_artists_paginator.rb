class OpenStudiosCatalogArtistsPaginator
  def initialize(artists, current_artist_id)
    @artists = artists
    @current = current_artist_id
  end

  def previous
    @artists[previous_index]
  end

  def next
    @artists[next_index]
  end

  private

  def current_index
    @current_index = @artists.find_index { |a| a.id == @current }
  end

  def previous_index
    return @artists.length - 1 unless current_index

    current_index - 1
  end

  def next_index
    return 0 unless current_index

    (current_index + 1) % @artists.count
  end
end
