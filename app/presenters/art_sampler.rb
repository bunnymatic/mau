class ArtSampler

  attr_reader :seed, :offset
  
  def initialize(seed: nil, offset: nil, number_of_images: nil)
    @seed = (seed || Time.zone.now.to_i)
    @offset = (offset || 0)
    @number_of_images_per_fetch = number_of_images || 10
  end

  def pieces
    get_random_pieces.map{|piece| ArtPiecePresenter.new(piece)}.compact
  end

  private
  def get_random_pieces
    ArtPiece.includes(:artist).where( {users: { state: :active } }).order("rand(#{seed})").limit(@number_of_images_per_fetch).offset(offset)
  end

end
