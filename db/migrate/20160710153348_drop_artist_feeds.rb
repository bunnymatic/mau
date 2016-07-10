class DropArtistFeeds < ActiveRecord::Migration
  def self.up
    drop_table :artist_feeds
  end

  def self.dpwm
    create_table :artist_feeds do |t|
      t.string :url
      t.string :feed
      t.boolean :active

      t.timestamps
    end

  end
end
