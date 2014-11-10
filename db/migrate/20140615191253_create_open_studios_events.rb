class CreateOpenStudiosEvents < ActiveRecord::Migration
  def change
    create_table :open_studios_events do |t|
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
