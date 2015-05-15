class ArtSampler

  NUM_IMAGES = 16 - 2
  def initialize(*args)
    super
  end

  def pieces 
    get_random_pieces.map{|piece| ArtPiecePresenter.new(piece)}
  end

  private
  def get_random_pieces
    ArtPiece.includes(:artist).where("users.state" => :active).order('rand()').limit(NUM_IMAGES)
  end

end
