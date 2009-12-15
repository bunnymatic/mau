class CreateArtistImages < ActiveRecord::Migration
  def self.up
    create_table :artist_images do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :artist_images
  end
end
