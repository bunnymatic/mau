module MainHelper
  # how many images do we need for the front page?
  @@NUM_IMAGES = 10
  def get_random_pieces(num_images=@@NUM_IMAGES)
    # get random set of art pieces and draw them
    @rand_pieces = []
    all = ArtPiece.all
    numpieces = all.length
    if numpieces > num_images
      @rand_pieces = choice(all, num_images)
    else 
      @rand_pieces = all
    end
  end
end
