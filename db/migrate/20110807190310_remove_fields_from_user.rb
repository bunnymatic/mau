class RemoveFieldsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :bio
    remove_column :users, :news
    remove_column :users, :osoct2010
    remove_column :users, :os2010
  end

  def self.down
    add_column :users, :os2010, :boolean
    add_column :users, :osoct2010, :boolean
    add_column :users, :news, :text
    add_column :users, :bio, :text
  end
end
