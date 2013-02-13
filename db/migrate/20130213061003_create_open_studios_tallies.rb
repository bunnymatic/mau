class CreateOpenStudiosTallies < ActiveRecord::Migration
  def self.up
    create_table :open_studios_tallies do |t|
      t.integer :count
      t.string :oskey
      t.date :recorded_on

      t.timestamps
    end
  end

  def self.down
    drop_table :open_studios_tallies
  end
end
