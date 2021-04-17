class OpenStudiosCatalogArtists < ArtistsPresenter
  def initialize
    super(os_only: true, sort_by_name: false)
  end

  def artists
    super.select(&:representative_piece).sort_by { |a| [a.broadcasting? ? 0 : 1, a.sortable_name] }
  end
end
