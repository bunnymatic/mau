class RemoveTaggingsTable < ActiveRecord::Migration
  def up
    drop_table :taggings
    drop_table :tags
  end

  def down
    create_table :tags do |t|
      t.column :name, :string, :null => false
    end
    add_index :tags, :name, :unique => true

    create_table :taggings do |t|
      t.column :tag_id, :integer, :null => false
      t.column :taggable_id, :integer, :null => false
      t.column :taggable_type, :string, :null => false
    end
  end
end
