class AddLatLngToStudioArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :lat, :double
    add_column :artists, :lng, :double
    add_column :studios,:lat, :double
    add_column :studios,:lng, :double
  end

  def self.down
    remove_column :artists, :lat, :double
    remove_column :artists, :lng, :double
    remove_column :studios,:lat, :double
    remove_column :studios,:lng, :double
  end
end
