class ArtSampler

  NUM_IMAGES = 15 - 4 # -4 for promo banner 2x2
  def initialize(view_context)
    @vc = view_context
  end
  
  def pieces 
    get_random_pieces.map{|piece| ArtPiecePresenter.new(@vc,piece)}
  end

  private
  def get_random_pieces
    # get random set of art pieces and draw them
    ArtPiece.includes(:artist).where("users.state" => :active).order('rand()').limit(NUM_IMAGES)
  end

end
