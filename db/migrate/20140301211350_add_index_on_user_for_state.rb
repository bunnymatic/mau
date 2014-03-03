class AddIndexOnUserForState < ActiveRecord::Migration
  def up
    add_index :users, :state
  end

  def down
    remove_index :users, :state
  end
end
