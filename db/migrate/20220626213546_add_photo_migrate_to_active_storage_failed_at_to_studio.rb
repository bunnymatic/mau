class AddPhotoMigrateToActiveStorageFailedAtToStudio < ActiveRecord::Migration[6.1]
  def change
    add_column :studios, :photo_migrate_to_active_storage_failed_at, :datetime
  end
end
