class AddSlugToArtPieceTags < ActiveRecord::Migration

  def up
    add_column :art_piece_tags, :slug, :string

    ArtPieceTag.reset_column_information
    ArtPieceTag.all.each { |a| a.touch; a.save }
  end

  def down
    remove_column :art_piece_tags, :slug
  end

end
