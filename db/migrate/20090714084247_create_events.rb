class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.timestamp :startdate
      t.timestamp :enddate
      t.text :description
      t.string :url
      t.string :image
      t.string :street
      t.string :city
      t.string :state
      t.integer :zip

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
