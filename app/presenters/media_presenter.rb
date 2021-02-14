class MediaPresenter
  attr_reader :medium

  def initialize(medium, page = nil, per_page = nil)
    @medium = medium
    @page = (page || 0).to_i
    @per_page = per_page
  end

  def all_art_pieces
    @all_art_pieces ||= raw_art_pieces.map { |piece| ArtPiecePresenter.new(piece) }
  end

  def paginator
    @paginator ||= MediumPagination.new(all_art_pieces, @medium, @page, @per_page)
  end

  private

  def raw_art_pieces
    @raw_art_pieces ||= @medium.art_pieces.joins(:artist).where(users: { state: :active }).order(updated_at: :desc)
  end
end
