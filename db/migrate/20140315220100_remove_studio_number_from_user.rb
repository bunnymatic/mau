class RemoveStudioNumberFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :studionumber
  end
  def down
    add_column :users, :studionumber, :string
  end

end
