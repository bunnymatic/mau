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

    # trigger create variants
    art_piece.image(:small)
    art_piece.image(:medium)
    art_piece.image(:large)

    if art_piece.persisted?
      emails = WatcherMailerList.instance.formatted_emails
      WatcherMailer.notify_new_art_piece(art_piece, emails).deliver_now if emails.present?
      trigger_artist_update
    end

    art_piece
  end

  def trigger_artist_update
    BryantStreetStudiosWebhook.artist_updated(artist.id)
  end
end
