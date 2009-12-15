class CreateArtistsEvents < ActiveRecord::Migration
  def self.up
    create_table :artists_events, :id => false do |t|
      t.integer :event_id
      t.integer :artist_id
    end
  end

  def self.down
    drop_table :artists_events
  end
end
