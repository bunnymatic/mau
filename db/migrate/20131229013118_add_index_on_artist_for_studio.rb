class AddIndexOnArtistForStudio < ActiveRecord::Migration
  def change
    add_index :users, :studio_id
  end
end
