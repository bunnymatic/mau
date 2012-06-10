class CreateApplicationEvents < ActiveRecord::Migration
  def self.up
    create_table :application_events do |t|
      t.string :type
      t.string :message
      t.text :data # store hash of data to go along with event

      t.timestamps
    end
  end

  def self.down
    drop_table :application_events
  end
end
