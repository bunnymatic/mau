class AddLatLngToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :lat, :double
    add_column :events, :lng, :double
  end

  def self.down
    remove_column :events, :lat
    remove_column :events, :lng
  end
end
