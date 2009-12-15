class AddUrlsToArtist < ActiveRecord::Migration
  def self.up
      add_column :artists, :facebook, :string, :limit => 200
      add_column :artists, :twitter, :string, :limit => 200
      add_column :artists, :blog, :string, :limit => 200
      add_column :artists, :myspace, :string, :limit => 200
      add_column :artists, :flickr, :string, :limit => 200
  end

  def self.down
      remove_column :artists, :facebook
      remove_column :artists, :twitter
      remove_column :artists, :blog
      remove_column :artists, :myspace
      remove_column :artists, :flickr
  end
end
