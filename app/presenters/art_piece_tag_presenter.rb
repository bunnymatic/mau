# frozen_string_literal: true

class ArtPieceTagPresenter
  attr_reader :tag

  def initialize(tag, page = nil, per_page = nil)
    @tag = tag
    @page = (page || 0).to_i
    @per_page = per_page
  end

  def art_pieces
    @art_pieces ||= tagged_art_pieces.map { |piece| ArtPiecePresenter.new(piece) }
  end

  def paginator
    ArtPieceTagPagination.new(art_pieces, @tag, @page, @per_page)
  end

  private

  def tagged_art_pieces
    @tagged_art_pieces ||= tag.art_pieces.joins(:artist).where(users: { state: :active }).order(updated_at: :desc)
  end
end
