# frozen_string_literal: true
class ArtSampler
  attr_reader :seed, :offset

  NUM_NEW_ART_PIECES = 2

  def initialize(seed: nil, offset: nil, number_of_images: nil)
    @seed = (seed || Time.zone.now.to_i)
    @offset = (offset || 0).to_i
    @number_of_images_per_fetch = number_of_images || 10
  end

  def pieces
    @pieces ||= fetch_pieces.map{|piece| ArtPiecePresenter.new(piece)}.compact
  end

  private

  def fetch_pieces
    result = []
    result += new_pieces if (offset < NUM_NEW_ART_PIECES)
    result += random_pieces-new_pieces
  end

  def random_pieces
    ArtPiece.includes(:artist)
            .where( users: { state: :active })
            .order("rand(#{seed})")
            .limit(@number_of_images_per_fetch)
            .offset(offset)
  end

  def new_pieces
    @new_pieces ||= ArtPiece.includes(:artist)
                            .where( users: { state: :active })
                            .order('art_pieces.created_at desc')
                            .limit(Artist::MAX_PIECES*NUM_NEW_ART_PIECES)
                            .uniq_by(&:artist_id)
                            .first(NUM_NEW_ART_PIECES)
  end
end
