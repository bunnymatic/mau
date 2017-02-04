class DropTableFeaturedArtistQueue < ActiveRecord::Migration[5.0]
  def down
    create_table :featured_artist_queue do |t|
      t.integer :artist_id
      t.timestamp :featured
      t.float :position
    end
    add_index "featured_artist_queue", ["position"], :name => "index_featured_artist_queue_on_position"
  end

  def up
    remove_index "featured_artist_queue", :name => "index_featured_artist_queue_on_position"
    drop_table :featured_artist_queue
  end
end
