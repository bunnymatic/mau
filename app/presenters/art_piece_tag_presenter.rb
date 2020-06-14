# frozen_string_literal: true

class ArtPieceTagPresenter
  attr_reader :tag

  def initialize(tag, mode)
    @tag = tag
    @mode = mode || 'p'
  end

  def art_pieces
    @art_pieces ||=
      begin
        pieces = (by_artist? ? pieces_by_artist : tagged_art_pieces).compact.sort_by(&:updated_at).reverse
        pieces.map { |p| ArtPiecePresenter.new(p) }
      end
  end

  private

  def tagged_art_pieces
    @tagged_art_pieces ||= tag.art_pieces.compact.select { |ap| ap.artist.try(:active?) }
  end

  def by_artist?
    @mode != 'p'
  end

  def pieces_by_artist
    @pieces_by_artist ||=
      begin
        {}.tap do |artists_works|
          tagged_art_pieces.each do |art|
            artist = art.try(:artist)
            artists_works[artist] = art unless artists_works.key?(artist)
          end
        end.values
      end
  end
end
