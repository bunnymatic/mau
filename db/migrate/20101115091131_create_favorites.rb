class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.timestamps
      t.integer :obj_id
      t.string :obj_type
      t.integer :user_id
    end
  end

  def self.down
    drop_table :favorites
  end
end
