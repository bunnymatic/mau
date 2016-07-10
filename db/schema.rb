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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160710153348) do

  create_table "application_events", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.string   "message",    limit: 255
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "art_piece_tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  create_table "art_pieces", force: :cascade do |t|
    t.string   "filename",           limit: 255
    t.string   "title",              limit: 255
    t.text     "description",        limit: 65535
    t.string   "dimensions",         limit: 255
    t.integer  "artist_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "medium_id",          limit: 4
    t.integer  "year",               limit: 4
    t.integer  "position",           limit: 4,     default: 0
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
  end

  add_index "art_pieces", ["artist_id"], name: "index_art_pieces_on_artist_id", using: :btree
  add_index "art_pieces", ["medium_id"], name: "index_art_pieces_on_medium_id", using: :btree

  create_table "art_pieces_tags", id: false, force: :cascade do |t|
    t.integer "art_piece_tag_id", limit: 4
    t.integer "art_piece_id",     limit: 4
  end

  create_table "artist_images", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_infos", force: :cascade do |t|
    t.integer  "artist_id",                  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio",                        limit: 65535
    t.text     "news",                       limit: 65535
    t.string   "street",                     limit: 255
    t.string   "city",                       limit: 200
    t.string   "addr_state",                 limit: 4
    t.string   "facebook",                   limit: 200
    t.string   "twitter",                    limit: 200
    t.string   "blog",                       limit: 200
    t.string   "myspace",                    limit: 200
    t.string   "flickr",                     limit: 200
    t.integer  "zip",                        limit: 4
    t.integer  "max_pieces",                 limit: 4,     default: 20
    t.string   "studionumber",               limit: 255
    t.float    "lat",                        limit: 24
    t.float    "lng",                        limit: 24
    t.string   "open_studios_participation", limit: 255
    t.string   "pinterest",                  limit: 255
    t.string   "instagram",                  limit: 255
  end

  add_index "artist_infos", ["artist_id"], name: "index_artist_infos_on_artist_id", unique: true, using: :btree

  create_table "artist_profile_images", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blacklist_domains", force: :cascade do |t|
    t.string   "domain",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cms_documents", force: :cascade do |t|
    t.string   "page",       limit: 255
    t.string   "section",    limit: 255
    t.text     "article",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
  end

  add_index "cms_documents", ["user_id"], name: "index_cms_documents_on_user_id", using: :btree

  create_table "email_list_memberships", force: :cascade do |t|
    t.integer "email_id",      limit: 4
    t.integer "email_list_id", limit: 4
  end

  create_table "email_lists", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_lists", ["type"], name: "index_email_lists_on_type", unique: true, using: :btree

  create_table "emails", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["email"], name: "index_emails_on_email", unique: true, using: :btree

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "favoritable_id",   limit: 4
    t.string   "favoritable_type", limit: 255
    t.integer  "user_id",          limit: 4
  end

  add_index "favorites", ["favoritable_type", "favoritable_id", "user_id"], name: "index_favorites_uniq_on_user_and_favorite", unique: true, using: :btree

  create_table "featured_artist_queue", force: :cascade do |t|
    t.integer  "artist_id", limit: 4
    t.datetime "featured"
    t.float    "position",  limit: 24
  end

  add_index "featured_artist_queue", ["position"], name: "index_featured_artist_queue_on_position", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.string   "subject",    limit: 255
    t.string   "email",      limit: 255
    t.string   "login",      limit: 255
    t.string   "page",       limit: 255
    t.text     "comment",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",        limit: 255
    t.string   "skillsets",  limit: 255
    t.string   "bugtype",    limit: 255
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "media", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  add_index "media", ["slug"], name: "index_media_on_slug", unique: true, using: :btree

  create_table "open_studios_events", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "key",               limit: 255
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size",    limit: 4
    t.datetime "logo_updated_at"
    t.string   "title",             limit: 255, default: "Open Studios", null: false
  end

  create_table "open_studios_tallies", force: :cascade do |t|
    t.integer  "count",       limit: 4
    t.string   "oskey",       limit: 255
    t.date     "recorded_on"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "promoted_events", force: :cascade do |t|
    t.integer  "event_id",     limit: 4
    t.datetime "publish_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "role",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  create_table "scammers", force: :cascade do |t|
    t.text     "email",      limit: 65535
    t.text     "name",       limit: 65535
    t.integer  "faso_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studios", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "street",             limit: 255
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.integer  "zip",                limit: 4
    t.string   "url",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_image",      limit: 255
    t.float    "lat",                limit: 53
    t.float    "lng",                limit: 53
    t.string   "cross_street",       limit: 255
    t.string   "phone",              limit: 255
    t.string   "slug",               limit: 255
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.integer  "position",           limit: 4,   default: 1000
  end

  add_index "studios", ["slug"], name: "index_studios_on_slug", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 40
    t.string   "name",                      limit: 100, default: ""
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 128, default: "",                                                               null: false
    t.string   "password_salt",             limit: 128, default: "",                                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 40
    t.datetime "remember_token_expires_at"
    t.string   "firstname",                 limit: 40
    t.string   "lastname",                  limit: 40
    t.string   "nomdeplume",                limit: 80
    t.string   "url",                       limit: 200
    t.string   "profile_image",             limit: 200
    t.integer  "studio_id",                 limit: 4
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.string   "state",                     limit: 255, default: "passive"
    t.datetime "deleted_at"
    t.string   "reset_code",                limit: 40
    t.string   "email_attrs",               limit: 255, default: "{\"fromartist\": true, \"favorites\": true, \"fromall\": true}"
    t.string   "type",                      limit: 255, default: "Artist"
    t.date     "mailchimp_subscribed_at"
    t.string   "persistence_token",         limit: 255
    t.integer  "login_count",               limit: 4,   default: 0,                                                                null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip",             limit: 255
    t.string   "current_login_ip",          limit: 255
    t.string   "slug",                      limit: 255
    t.string   "photo_file_name",           limit: 255
    t.string   "photo_content_type",        limit: 255
    t.integer  "photo_file_size",           limit: 4
    t.datetime "photo_updated_at"
  end

  add_index "users", ["last_request_at"], name: "index_users_on_last_request_at", using: :btree
  add_index "users", ["login"], name: "index_artists_on_login", unique: true, using: :btree
  add_index "users", ["persistence_token"], name: "index_users_on_persistence_token", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["state"], name: "index_users_on_state", using: :btree
  add_index "users", ["studio_id"], name: "index_users_on_studio_id", using: :btree

end
