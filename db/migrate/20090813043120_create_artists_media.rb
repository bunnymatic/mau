class CreateArtistsMedia < ActiveRecord::Migration
  def self.up
    create_table :artists_media, :id => false do |t|
      t.integer :medium_id
      t.integer :artist_id
    end
  end

  def self.down
    drop_table :artists_media
  end
end
