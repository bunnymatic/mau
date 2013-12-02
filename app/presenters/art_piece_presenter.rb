class ArtPiecePresenter

  attr_reader :art_piece
  delegate :id, :year, :medium, :get_path, :artist, :title, :to => :art_piece

  def initialize(view_context, art_piece)
    @view_context = view_context
    @art_piece = art_piece
  end

  def favorites_count
    @favorites_count ||= Favorite.art_pieces.where(:favoritable_id => @art_piece.id).count
    @favorites_count if @favorites_count > 0
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

  def width
    image_dimensions[:medium].first
  end

  def css_width
    "width: #{width}px;"
  end

  def has_medium?
    medium.present?
  end

  def zoomed
    @zoomed ||= art_piece.get_path('large')
  end

  def zoomed_width
    image_dimensions[:large][0]
  end

  def zoomed_height
    image_dimensions[:large][1]
  end

  def edit_path
    @view_context.edit_art_piece_path(art_piece)
  end

  def path
    @view_context.art_piece_path(art_piece)
  end

end
