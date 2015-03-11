class ArtPiecePresenter < ViewPresenter

  attr_reader :art_piece
  delegate :id, :portrait?, :year, :medium, :get_path, :artist, :title, :updated_at, :to_param, :to => :art_piece

  def initialize(art_piece)
    @art_piece = art_piece
  end

  def favorites_count
    @favorites_count ||= Favorite.art_pieces.where(:favoritable_id => @art_piece.id).count
    @favorites_count if @favorites_count > 0
  end

  def orientation
    portrait? ? :portrait : :landscape
  end

  def artist_name
    artist.get_name
  end

  def has_medium?
    medium.present?
  end

  def has_tags?
    tags.present?
  end

  def tags
    @tags ||= @art_piece.uniq_tags
  end

  def has_year?
    year.present? and year.to_i > 1899
  end

  def has_dimensions?
    @art_piece.dimensions.present?
  end

  def display_dimensions
    @art_piece.dimensions
  end

  def image_dimensions
    @dimensions ||= art_piece.compute_dimensions
  end

  def width(sz = :medium)
    image_dimensions[sz].first
  end

  def height(sz = :medium)
    image_dimensions[sz].last
  end

  def zoomed
    @zoomed ||= art_piece.get_path('large')
  end

  def path
    url_helpers.art_piece_path(art_piece)
  end

  alias_method :show_path, :path
  alias_method :destroy_path, :path

  def edit_path
    url_helpers.edit_art_piece_path(art_piece)
  end

  def artist_path
    url_helpers.artist_path(artist.artist)
  end

end
