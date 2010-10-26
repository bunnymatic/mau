class DumpEventsTables < ActiveRecord::Migration
  def self.up
    drop_table :artists_events
  end

  def self.down
  end
end
