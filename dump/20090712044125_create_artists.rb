class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.string :firstname
      t.string :lastname
      t.string :nomdeplume
      t.string :phone
      t.string :email
      t.string :url
      t.string :profile_image
      t.string :street
      t.string :city
      t.string :state
      t.integer :zip
      t.text :bio
      t.integer :studio_id

      t.timestamps
    end
  end

  def self.down
    drop_table :artists
  end
end
