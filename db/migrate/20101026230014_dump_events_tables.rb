class DumpEventsTables < ActiveRecord::Migration
  def self.up
    drop_table :artists_events
  end

  def self.down
    create_table :artists_events do |t|
	t.timestamps
	end
  end
end
