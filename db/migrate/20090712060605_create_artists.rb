class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table "artists", :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100, :default => '', :null => true
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :firstname, :string, :limit => 40
      t.column :lastname, :string, :limit => 40
      t.column :nomdeplume, :string, :limit => 80
      t.column :phone, :string, :limit => 16
      t.column :url, :string, :limit => 200
      t.column :profile_image, :string, :limit => 200
      t.column :street, :string, :limit => 200
      t.column :city, :string, :limit => 200
      t.column :state, :string, :limit => 4
      t.column :zip, :integer
      t.column :bio, :text 
      t.column :news, :text 
      t.column :role_id, :integer
      t.column :studio_id, :integer


    end
    add_index :artists, :login, :unique => true
  end

  def self.down
    drop_table "artists"
  end
end
