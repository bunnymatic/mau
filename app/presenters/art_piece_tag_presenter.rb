# frozen_string_literal: true
class ArtPieceTagPresenter
  attr_reader :tag

  def initialize(tag, mode)
    @tag = tag
    @mode = mode || 'p'
  end

  def art_pieces
    @pieces ||=
      begin
        pieces = (by_artist? ? pieces_by_artist : tagged_art_pieces).compact.sort_by(&:updated_at).reverse
        pieces.map { |p| ArtPiecePresenter.new(p) }
      end
  end

  def safe_name
    safe_join([HtmlEncoder.encode(name).gsub(' ', '&nbsp;')])
  end

  private

  def tagged_art_pieces
    @tagged_art_pieces ||= ArtPiecesTag.includes(:art_piece)
                                       .where(art_piece_tag_id: tag.id)
                                       .map(&:art_piece)
                                       .compact.select { |ap| ap.artist.try(:active?) }
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
            if artist && artist.active? && !artists_works.key?(artist)
              artists_works[artist] = art
            end
          end
        end.values
      end
  end
end
