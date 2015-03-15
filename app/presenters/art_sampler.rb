class ArtSampler

  NUM_IMAGES = 15
  def pieces
    get_random_pieces.map{|piece| ArtPiecePresenter.new(piece)}
  end

  private
  def get_random_pieces
    # get random set of art pieces and draw them
    ArtPiece.includes(:artist).where("users.state" => :active).order('rand()').limit(NUM_IMAGES)
  end

end
