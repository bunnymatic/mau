class DelRoleIdFromArtist < ActiveRecord::Migration
  def self.up
    remove_column :artists, :role_id
  end

  def self.down
  end
end
