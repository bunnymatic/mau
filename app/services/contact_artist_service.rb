class ContactArtistService
  def self.contact_about_art(contact_info)
    return unless contact_info.valid?

    art_piece = ArtPiece.find(contact_info.art_piece_id)
    artist = art_piece.artist
    ArtistMailer.contact_about_art(artist, art_piece, contact_info.to_h).deliver_later
  end
end
