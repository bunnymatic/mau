class AddStateToArtist < ActiveRecord::Migration
  def self.up
    rename_column :artists, :state, :addr_state
    add_column :artists, :activation_code,           :string, :limit => 40
    add_column :artists, :activated_at,              :datetime
    add_column :artists, :state,                     :string, :null => :no, :default => 'passive'
    add_column :artists, :deleted_at,                :datetime
  end

  def self.down
    remove_column :artists, :activation_code
    remove_column :artists, :activated_at
    remove_column :artists, :state
    remove_column :artists, :deleted_at
    rename_column :artists, :addr_state, :state
  end
end
