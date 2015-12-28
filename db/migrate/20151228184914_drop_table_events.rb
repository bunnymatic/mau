class DropTableEvents < ActiveRecord::Migration
  def up
    drop_table :events
  end

  def down
    create_table "events", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.string   "tweet"
      t.string   "street"
      t.string   "venue"
      t.string   "state"
      t.string   "city"
      t.string   "zip"
      t.datetime "starttime"
      t.datetime "endtime"
      t.string   "url"
      t.float    "lat"
      t.float    "lng"
      t.integer  "user_id"
      t.datetime "published_at"
      t.datetime "reception_starttime"
      t.datetime "reception_endtime"
      t.datetime "created_at",          :default => '2014-05-31 19:44:53'
      t.datetime "updated_at",          :default => '2014-05-31 19:44:54'
    end
  end
end
