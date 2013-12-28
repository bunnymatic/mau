class DropTableFlaxArtSubmissions < ActiveRecord::Migration
  def up
    drop_table :flax_art_submissions
  end

  def down
  end
end
