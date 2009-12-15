class CreateArtistsTags < ActiveRecord::Migration
  def self.up
    create_table :artists_tags, :id => false do |t|
      t.integer :tag_id
      t.integer :artist_id
    end
  end

  def self.down
    drop_table :artists_tags
  end
end
