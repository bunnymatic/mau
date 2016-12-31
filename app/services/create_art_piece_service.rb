class CreateArtPieceService

  attr_reader :params, :artist

  def initialize(artist, art_piece_params)
    @params = art_piece_params
    @artist = artist
  end

  def create_art_piece
    prepare_tags_params
    art_piece = artist.art_pieces.build(params)
    art_piece.save
    art_piece
  end

  private
  def prepare_tags_params
    tags_string = params[:tags]
    tag_names = (tags_string || '').split(",").map{|name| name.strip.downcase}.compact.uniq
    self.params[:tags] = tag_names.map{|name| ArtPieceTag.find_or_create_by(name: name)}
  end

end
