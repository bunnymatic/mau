class RecreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events, :force => true do |t|
      t.string :title
      t.text :description
      t.string :tweet
      t.string :street
      t.string :venue
      t.string :state
      t.string :city
      t.string :zip
      t.timestamp :starttime
      t.timestamp :endtime
      t.string :url
    end
  end

  def self.down
    drop_table :events
  end
end

