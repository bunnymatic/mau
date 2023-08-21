class CreateArtPieceService
  attr_reader :params, :artist, :file

  include ArtPieceServiceTagsHandler

  def self.call(artist, art_piece_params)
    new(artist, art_piece_params).call
  end

  def initialize(artist, art_piece_params)
    @params = art_piece_params
    @artist = artist
    @file = @params.delete(:photo)
  end

  def call
    prepare_tags_params
    art_piece = artist.art_pieces.build(params)
    art_piece.photo.attach(file)
    art_piece.save

    emails = WatcherMailerList.first&.formatted_emails
    WatcherMailer.notify_new_art_piece(art_piece, emails).deliver_now if art_piece.persisted? && emails.present?

    # trigger create medium variant
    art_piece&.image(:medium)
    art_piece&.image(:large)

    art_piece
  end
end
