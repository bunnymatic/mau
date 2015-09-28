class AddAttachmentToArtPiece < ActiveRecord::Migration
  def change
    add_attachment :art_pieces, :photo
  end
end
