class AddResetCodeToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :reset_code, :string, :limit => 40

  end

  def self.down
    remove_column :artists, :reset_code
  end
end
