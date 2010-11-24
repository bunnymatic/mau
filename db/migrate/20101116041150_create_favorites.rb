class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.timestamps
      t.integer :favoritable_id
      t.string :favoritable_type
      t.integer :user_id
    end
  end

  def self.down
    drop_table :favorites
  end
end
