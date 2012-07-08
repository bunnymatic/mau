class DropEventSubscribers < ActiveRecord::Migration
  def self.up
    drop_table :event_subscribers
  end

  def self.down
    create_table :event_subscribers do |t|
      t.string :url
      t.string :event_type

      t.timestamps
    end
  end
end

