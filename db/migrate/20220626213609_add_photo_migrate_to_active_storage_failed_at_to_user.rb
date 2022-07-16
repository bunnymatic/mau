class AddPhotoMigrateToActiveStorageFailedAtToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :photo_migrate_to_active_storage_failed_at, :datetime
  end
end
