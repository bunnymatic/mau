class AddAttachmentToArtPiece < ActiveRecord::Migration
  def up
    add_attachment :art_pieces, :photo
  end
  def down
    add_attachment :art_pieces, :photo
  end
end
