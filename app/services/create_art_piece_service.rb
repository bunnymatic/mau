class CreateArtPieceService
  attr_reader :params, :artist

  include ArtPieceServiceTagsHandler

  def initialize(artist, art_piece_params)
    @params = art_piece_params
    @artist = artist
  end

  def create_art_piece
    prepare_tags_params
    art_piece = artist.art_pieces.build(params)
    art_piece.save

    emails = WatcherMailerList.first&.formatted_emails
    WatcherMailer.notify_new_art_piece(art_piece, emails).deliver_now if art_piece.persisted? && emails.present?

    art_piece
  end
end
