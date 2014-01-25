class RemoveColumnPhoneFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :phone
  end

  def down
    add_column :users, :phone, :string, :limit => 16
  end
end
