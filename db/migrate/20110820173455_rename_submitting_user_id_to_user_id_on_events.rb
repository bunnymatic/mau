class RenameSubmittingUserIdToUserIdOnEvents < ActiveRecord::Migration
  def self.up
    rename_column :events, :submitting_user_id, :user_id
  end

  def self.down
    rename_column :events, :user_id, :submitting_user_id
  end
end
