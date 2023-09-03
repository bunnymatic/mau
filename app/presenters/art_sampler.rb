class ArtSampler
  attr_reader :seed, :offset

  NUM_NEW_ART_PIECES = 2

  def initialize(seed: nil, offset: nil, number_of_images: nil)
    @seed = (seed || Time.zone.now).to_i
    @offset = (offset || 0).to_i
    @number_of_images_per_fetch = number_of_images || 10
  end

  def pieces
    @pieces ||= fetch_pieces.filter_map { |piece| ArtPiecePresenter.new(piece) }
  end

  private

  def fetch_pieces
    result = offset < NUM_NEW_ART_PIECES ? new_pieces : []
    result + random_pieces
  end

  def random_pieces
    # Though including open studios events in this for AREL performance
    # it ruins the random order and limit/offset so that we end up with duplicate
    # art pieces in the samples.  So please leave it out
    ArtPiece.distinct
            .includes(:artist)
            .where(users: { state: :active })
            .where.not(id: new_pieces.pluck(:id))
            .order(Arel.sql("rand(#{seed})"))
            .limit(@number_of_images_per_fetch)
            .offset(offset)
  end

  def new_pieces
    @new_pieces ||= ArtPiece.includes(:artist)
                            .where(users: { state: :active })
                            .order('art_pieces.created_at desc')
                            .limit(Artist::MAX_PIECES * NUM_NEW_ART_PIECES)
                            .uniq_by(&:artist_id)
                            .first(NUM_NEW_ART_PIECES)
  end
end
