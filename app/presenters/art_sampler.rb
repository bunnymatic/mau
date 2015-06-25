class ArtSampler

  NUM_IMAGES = 10
  attr_reader :seed, :offset
  def initialize(seed = nil, offset = nil)
    @seed ||= Time.zone.now.to_i
    @offset ||= 0
  end

  def pieces
    get_random_pieces.map{|piece| ArtPiecePresenter.new(piece)}
  end

  private
  def get_random_pieces
    ArtPiece.includes(:artist).where( {users: { state: :active } }).order("rand(#{seed})").limit(NUM_IMAGES).offset(offset)
  end

end
