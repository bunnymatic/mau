class UpdateUserFieldsForAuthlogic < ActiveRecord::Migration
  def up
    change_column :users, :crypted_password, :string, :limit => 128, :null => false, :default => ''
    change_column :users, :salt, :string, :limit => 128, :null => false, :default => ''
    rename_column :users, :salt, :password_salt

    add_column :users, :persistence_token, :string
    add_column :users, :login_count, :integer, :default => 0, :null => false
    add_column :users, :last_request_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_ip, :string
    add_column :users, :current_login_ip, :string

    add_index :users, :persistence_token
    add_index :users, :last_request_at
  end

  def down
    remove_column :users, :login_count
    remove_column :users, :last_request_at
    remove_column :users, :last_login_at
    remove_column :users, :current_login_at
    remove_column :users, :last_login_ip
    remove_column :users, :current_login_ip
    remove_index :users, :persistence_token
    remove_index :users, :last_request_at

    remove_column :users, :persistence_token
    rename_column :users, :password_salt, :salt
  end
end
