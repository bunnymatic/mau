class ArtPieceTagPresenter

  attr_reader :tag

  def initialize(tag, mode)
    @tag = tag
    @mode = mode || 'p'
  end

  def art_pieces
    @pieces ||= (by_artist? ? pieces_by_artist : tagged_art_pieces).sort_by(&:updated_at).reverse
  end

  private
  def tagged_art_pieces
    @tagged_art_pieces ||= ArtPiecesTag.where(:art_piece_tag_id => tag.id).map(&:art_piece)
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
            if artist && artist.is_active? && !artists_works.has_key?(artist)
              artists_works[artist] = art
            end
          end
        end.values
    end
  end

end
