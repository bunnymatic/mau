# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150615063552) do

  create_table "application_events", :force => true do |t|
    t.string   "type"
    t.string   "message"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "art_piece_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "art_pieces", :force => true do |t|
    t.string   "filename"
    t.string   "title"
    t.text     "description"
    t.string   "dimensions"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "medium_id"
    t.integer  "year"
    t.integer  "image_height", :default => 0
    t.integer  "image_width",  :default => 0
    t.integer  "position",     :default => 0
  end

  add_index "art_pieces", ["artist_id"], :name => "index_art_pieces_on_artist_id"
  add_index "art_pieces", ["medium_id"], :name => "index_art_pieces_on_medium_id"

  create_table "art_pieces_tags", :id => false, :force => true do |t|
    t.integer "art_piece_tag_id"
    t.integer "art_piece_id"
  end

  create_table "artist_feeds", :force => true do |t|
    t.string   "url"
    t.string   "feed"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_infos", :force => true do |t|
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio"
    t.text     "news"
    t.string   "street"
    t.string   "city",                       :limit => 200
    t.string   "addr_state",                 :limit => 4
    t.string   "facebook",                   :limit => 200
    t.string   "twitter",                    :limit => 200
    t.string   "blog",                       :limit => 200
    t.string   "myspace",                    :limit => 200
    t.string   "flickr",                     :limit => 200
    t.integer  "zip"
    t.integer  "max_pieces",                                :default => 20
    t.string   "studionumber"
    t.float    "lat"
    t.float    "lng"
    t.string   "open_studios_participation"
    t.string   "pinterest"
    t.string   "instagram"
  end

  add_index "artist_infos", ["artist_id"], :name => "index_artist_infos_on_artist_id", :unique => true

  create_table "artist_profile_images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blacklist_domains", :force => true do |t|
    t.string   "domain"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cms_documents", :force => true do |t|
    t.string   "page"
    t.string   "section"
    t.text     "article"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "cms_documents", ["user_id"], :name => "index_cms_documents_on_user_id"

  create_table "email_list_memberships", :force => true do |t|
    t.integer "email_id"
    t.integer "email_list_id"
  end

  create_table "email_lists", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_lists", ["type"], :name => "index_email_lists_on_type", :unique => true

  create_table "emails", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["email"], :name => "index_emails_on_email", :unique => true

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

  create_table "favorites", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "favoritable_id"
    t.string   "favoritable_type"
    t.integer  "user_id"
  end

  create_table "featured_artist_queue", :force => true do |t|
    t.integer  "artist_id"
    t.datetime "featured"
    t.float    "position"
  end

  add_index "featured_artist_queue", ["position"], :name => "index_featured_artist_queue_on_position"

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

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "media", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_studios_events", :force => true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "key"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "title",             :default => "Open Studios", :null => false
  end

  create_table "open_studios_tallies", :force => true do |t|
    t.integer  "count"
    t.string   "oskey"
    t.date     "recorded_on"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "promoted_events", :force => true do |t|
    t.integer  "event_id"
    t.datetime "publish_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "scammers", :force => true do |t|
    t.text     "email"
    t.text     "name"
    t.integer  "faso_id"
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
    t.string   "cross_street"
    t.string   "phone"
    t.string   "slug"
  end

  add_index "studios", ["slug"], :name => "index_studios_on_slug", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 128, :default => "",                                                               :null => false
    t.string   "password_salt",             :limit => 128, :default => "",                                                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "firstname",                 :limit => 40
    t.string   "lastname",                  :limit => 40
    t.string   "nomdeplume",                :limit => 80
    t.string   "url",                       :limit => 200
    t.string   "profile_image",             :limit => 200
    t.integer  "studio_id"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "reset_code",                :limit => 40
    t.integer  "image_height",                             :default => 0
    t.integer  "image_width",                              :default => 0
    t.string   "email_attrs",                              :default => "{\"fromartist\": true, \"favorites\": true, \"fromall\": true}"
    t.string   "type",                                     :default => "Artist"
    t.date     "mailchimp_subscribed_at"
    t.string   "persistence_token"
    t.integer  "login_count",                              :default => 0,                                                                :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "slug"
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_artists_on_login", :unique => true
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true
  add_index "users", ["state"], :name => "index_users_on_state"
  add_index "users", ["studio_id"], :name => "index_users_on_studio_id"

end
