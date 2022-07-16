class AddPhotoMigrateToActiveStorageFailedAtToArtPiece < ActiveRecord::Migration[6.1]
  def change
    add_column :art_pieces, :photo_migrate_to_active_storage_failed_at, :datetime
  end
end
