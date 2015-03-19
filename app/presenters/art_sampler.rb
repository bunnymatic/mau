class ArtSampler

  NUM_IMAGES = 15 - 2
  def initialize(*args)
    super
  end

  def pieces 
    get_random_pieces.map{|piece| ArtPiecePresenter.new(piece)}
  end

  def include_open_studios?
    @include_open_studios ||= (Artist.open_studios_participants.count > 10)
  end
  
  private
  def get_random_pieces
    # get random set of art pieces and draw them
    ArtPiece.includes(:artist).where("users.state" => :active).order('rand()').limit(NUM_IMAGES)

  end

end
