class UpdateArtPieceService

  attr_reader :art_piece, :params

  def initialize(art_piece, art_piece_params)
    @art_piece = art_piece
    @params = art_piece_params
  end

  def update_art_piece
    prepare_tags_params
    art_piece.update_attributes(params)
    art_piece
  end

  private
  def prepare_tags_params
    tags_string = params[:tags]
    tag_names = (tags_string || '').split(",").map{|name| name.strip.downcase}.compact.uniq
    self.params[:tags] = tag_names.map{|name| ArtPieceTag.find_or_create_by(name: name)}
  end

end
