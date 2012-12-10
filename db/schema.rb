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

ActiveRecord::Schema.define(:version => 20121209215245) do

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
    t.integer  "order"
  end

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
  end

  create_table "artist_profile_images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blacklist_domains", :force => true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_documents", :force => true do |t|
    t.string   "page"
    t.string   "section"
    t.text     "article"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "publish"
    t.datetime "reception_starttime"
    t.datetime "reception_endtime"
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

  create_table "flax_art_submissions", :force => true do |t|
    t.integer  "user_id"
    t.string   "art_piece_ids"
    t.boolean  "paid",          :default => false
    t.boolean  "accepted",      :default => false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_authorizations", :force => true do |t|
    t.string   "user_id"
    t.integer  "oauth_client_id"
    t.string   "code"
    t.integer  "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_clients", :force => true do |t|
    t.string   "name"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "redirect_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_tokens", :force => true do |t|
    t.string   "user_id"
    t.integer  "oauth_client_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.integer  "expires_at"
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
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",        :null => false
    t.integer "taggable_id",   :null => false
    t.string  "taggable_type", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "users", :force => true do |t|
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
    t.string   "email_attrs",                              :default => "{\"fromartist\": true, \"favorites\": true, \"fromall\": true}"
    t.string   "studionumber"
    t.string   "type",                                     :default => "Artist"
    t.date     "mailchimp_subscribed_at"
  end

  add_index "users", ["login"], :name => "index_artists_on_login", :unique => true

end
