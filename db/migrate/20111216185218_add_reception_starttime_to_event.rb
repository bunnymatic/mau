class AddReceptionStarttimeToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :reception_starttime, :timestamp
    add_column :events, :reception_endtime, :timestamp
  end

  def self.down
    remove_column :events, :reception_starttime
    remove_column :events, :reception_endtime
  end
end
