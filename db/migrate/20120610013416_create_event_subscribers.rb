class CreateEventSubscribers < ActiveRecord::Migration
  def self.up
    create_table :event_subscribers do |t|
      t.string :url
      t.string :event_type

      t.timestamps
    end
  end

  def self.down
    drop_table :event_subscribers
  end
end
