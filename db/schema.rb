# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100813143934) do

  create_table "art_pieces", :force => true do |t|
    t.string   "filename"
    t.string   "title"
    t.text     "description"
    t.string   "style"
    t.string   "dimensions"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "medium_id"
    t.integer  "year"
    t.integer  "image_height", :default => 0
    t.integer  "image_width",  :default => 0
  end

  create_table "art_pieces_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "art_piece_id"
  end

  create_table "artist_images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_profile_images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "firstname",                 :limit => 40
    t.string   "lastname",                  :limit => 40
    t.string   "nomdeplume",                :limit => 80
    t.string   "phone",                     :limit => 16
    t.string   "url",                       :limit => 200
    t.string   "profile_image",             :limit => 200
    t.string   "street",                    :limit => 200
    t.string   "city",                      :limit => 200
    t.string   "addr_state",                :limit => 4
    t.integer  "zip"
    t.text     "bio"
    t.text     "news"
    t.integer  "studio_id"
    t.string   "facebook",                  :limit => 200
    t.string   "twitter",                   :limit => 200
    t.string   "blog",                      :limit => 200
    t.string   "myspace",                   :limit => 200
    t.string   "flickr",                    :limit => 200
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "reset_code",                :limit => 40
    t.integer  "image_height",                             :default => 0
    t.integer  "image_width",                              :default => 0
    t.integer  "max_pieces",                               :default => 20
    t.integer  "representative_art_piece"
    t.string   "email_attrs",                              :default => "{\"fromartist\": true, \"mauadmin\": true, \"maunews\": true, \"fromall\": false}"
    t.boolean  "os2010",                                   :default => false
    t.float    "lat"
    t.float    "lng"
    t.boolean  "osoct2010",                                :default => false
  end

  add_index "artists", ["login"], :name => "index_artists_on_login", :unique => true

  create_table "artists_events", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "artist_id"
  end

  create_table "artists_roles", :id => false, :force => true do |t|
    t.integer "artist_id"
    t.integer "role_id"
  end

  create_table "dummyusers", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
  end

  add_index "dummyusers", ["login"], :name => "index_dummyusers_on_login", :unique => true

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "startdate"
    t.datetime "enddate"
    t.text     "description"
    t.string   "url"
    t.string   "image"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.string   "subject"
    t.string   "email"
    t.string   "login"
    t.string   "page"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "skillsets"
    t.string   "bugtype"
  end

  create_table "media", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studios", :force => true do |t|
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_image"
    t.integer  "image_height",  :default => 0
    t.integer  "image_width",   :default => 0
    t.float    "lat"
    t.float    "lng"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
