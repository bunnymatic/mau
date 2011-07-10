class CreateFeaturedArtistQueue < ActiveRecord::Migration
  def self.up
    create_table :featured_artist_queue do |t|
      t.integer :artist_id
      t.timestamp :featured
      t.float :position
    end
    add_index "featured_artist_queue", ["position"], :name => "index_featured_artist_queue_on_position"
  end

  def self.down
    drop_table :featured_artist_queue
  end
end
