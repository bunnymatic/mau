class RemoveUrlFromUsers < ActiveRecord::Migration[6.1]
  def up
    remove_column :users, :url
  end

  def down
    add_column :users, :url, :string, limit: 255
  end
end
