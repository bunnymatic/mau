class AddTiimestampsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :created_at, :datetime, :default => Time.now
    add_column :events, :updated_at, :datetime, :default => Time.now
  end
end
