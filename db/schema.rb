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

ActiveRecord::Schema.define(version: 20171223205227) do

  create_table "application_events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "type"
    t.string "message"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "art_piece_tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
  end

  create_table "art_pieces", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.string "dimensions"
    t.integer "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "medium_id"
    t.integer "year"
    t.integer "position", default: 0
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.index ["artist_id"], name: "index_art_pieces_on_artist_id"
    t.index ["medium_id"], name: "index_art_pieces_on_medium_id"
  end

  create_table "art_pieces_tags", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "art_piece_tag_id"
    t.integer "art_piece_id"
    t.index ["art_piece_id"], name: "index_art_pieces_tags_on_art_piece_id"
    t.index ["art_piece_tag_id"], name: "index_art_pieces_tags_on_art_piece_tag_id"
  end

  create_table "artist_images", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_infos", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "bio"
    t.string "street"
    t.string "city", limit: 200
    t.string "addr_state", limit: 4
    t.integer "zip"
    t.integer "max_pieces", default: 20
    t.string "studionumber"
    t.float "lat", limit: 24
    t.float "lng", limit: 24
    t.string "open_studios_participation"
    t.index ["artist_id"], name: "index_artist_infos_on_artist_id", unique: true
  end

  create_table "artist_profile_images", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blacklist_domains", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cms_documents", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "page"
    t.string "section"
    t.text "article"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_cms_documents_on_user_id"
  end

  create_table "email_list_memberships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "email_id"
    t.integer "email_list_id"
    t.index ["email_id"], name: "index_email_list_memberships_on_email_id"
    t.index ["email_list_id"], name: "index_email_list_memberships_on_email_list_id"
  end

  create_table "email_lists", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["type"], name: "index_email_lists_on_type", unique: true
  end

  create_table "emails", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_emails_on_email", unique: true
  end

  create_table "favorites", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "favoritable_id"
    t.string "favoritable_type"
    t.integer "user_id"
    t.index ["favoritable_type", "favoritable_id", "user_id"], name: "index_favorites_uniq_on_user_and_favorite", unique: true
  end

  create_table "feedbacks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "subject"
    t.string "email"
    t.string "login"
    t.string "page"
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "url"
    t.string "skillsets"
    t.string "bugtype"
  end

  create_table "friendly_id_slugs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 40
    t.datetime "created_at"
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "media", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.index ["slug"], name: "index_media_on_slug", unique: true
  end

  create_table "open_studios_events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "title", default: "Open Studios", null: false
  end

  create_table "open_studios_tallies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "count"
    t.string "oskey"
    t.date "recorded_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promoted_events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "event_id"
    t.datetime "publish_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "scammers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.text "email"
    t.text "name"
    t.integer "faso_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studios", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "street"
    t.string "city"
    t.string "state"
    t.integer "zip"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "profile_image"
    t.float "lat", limit: 53
    t.float "lng", limit: 53
    t.string "cross_street"
    t.string "phone"
    t.string "slug"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer "position", default: 1000
    t.index ["slug"], name: "index_studios_on_slug", unique: true
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "login", limit: 40
    t.string "name", limit: 100, default: ""
    t.string "email", limit: 100
    t.string "crypted_password", limit: 128, default: "", null: false
    t.string "password_salt", limit: 128, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_token", limit: 40
    t.datetime "remember_token_expires_at"
    t.string "firstname", limit: 40
    t.string "lastname", limit: 40
    t.string "nomdeplume", limit: 80
    t.string "url", limit: 200
    t.string "profile_image", limit: 200
    t.integer "studio_id"
    t.string "activation_code", limit: 40
    t.datetime "activated_at"
    t.string "state", default: "passive"
    t.datetime "deleted_at"
    t.string "reset_code", limit: 40
    t.string "email_attrs", default: "{\"fromartist\": true, \"favorites\": true, \"fromall\": true}"
    t.string "type", default: "Artist"
    t.date "mailchimp_subscribed_at"
    t.string "persistence_token"
    t.integer "login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string "last_login_ip"
    t.string "current_login_ip"
    t.string "slug"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.text "links"
    t.index ["last_request_at"], name: "index_users_on_last_request_at"
    t.index ["login"], name: "index_artists_on_login", unique: true
    t.index ["persistence_token"], name: "index_users_on_persistence_token"
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["state"], name: "index_users_on_state"
    t.index ["studio_id"], name: "index_users_on_studio_id"
  end

end
