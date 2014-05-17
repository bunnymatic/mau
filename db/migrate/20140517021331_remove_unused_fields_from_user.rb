class RemoveUnusedFieldsFromUser < ActiveRecord::Migration
  DUPLICATE_LINK_FIELDS = %w|facebook twitter blog myspace flickr|

  def up
    DUPLICATE_LINK_FIELDS.each do |fld|
      remove_column :users, fld
    end
    remove_column :users, :max_pieces
  end

  def down
    DUPLICATE_LINK_FIELDS.each do |fld|
      add_column :users, fld, :string, :limit => 255
    end
    add_column :users, :max_pieces, :integer
  end
end
