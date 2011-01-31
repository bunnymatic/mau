class CreateFlaxArtSubmissionTable < ActiveRecord::Migration
  def self.up
    create_table :flax_art_submissions do |t|
      t.integer :user_id
      t.string :art_piece_ids
      t.boolean :paid, :default => false
      t.boolean :accepted, :default => false
      t.string :comments
      t.timestamps
    end
  end

  def self.down
    drop_table :flax_art_submissions
  end
end
