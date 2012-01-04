class CreateArtistFeeds < ActiveRecord::Migration
  def self.up
    create_table :artist_feeds do |t|
      t.string :url
      t.string :feed
      t.boolean :active

      t.timestamps
    end
    
  end

  def self.down
    drop_table :artist_feeds
  end
end
