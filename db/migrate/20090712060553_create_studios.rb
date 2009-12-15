class CreateStudios < ActiveRecord::Migration
  def self.up
    create_table :studios do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.integer :zip
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :studios
  end
end
