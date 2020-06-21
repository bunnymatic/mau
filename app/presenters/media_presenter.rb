# frozen_string_literal: true

class MediaPresenter
  include ArtistOrPiece

  attr_reader :medium

  def initialize(medium, page = nil, mode = nil, per_page = nil)
    @medium = medium
    @page = (page || 0).to_i
    @mode_string = mode || 'p'
    @per_page = per_page
  end

  def all_art_pieces
    @all_art_pieces ||=
      begin
        if by_artists?
          art_pieces_by_artist
        else
          raw_art_pieces
        end
      end.map { |a| ArtPiecePresenter.new(a) }
  end

  def art_pieces_by_artist
    @art_pieces_by_artist ||=
      begin
        {}.tap do |bucket|
          raw_art_pieces.each do |piece|
            bucket[piece.artist_id] = piece unless bucket.key? piece.artist_id
          end
        end.values.sort_by(&:updated_at).reverse
      end
  end

  def paginator
    @paginator ||= MediumPagination.new(all_art_pieces, @medium, @page, @mode_string, @per_page)
  end

  private

  def raw_art_pieces
    @raw_art_pieces ||= @medium.art_pieces.joins(:artist).where(users: { state: :active }).order(updated_at: :desc)
  end
end
