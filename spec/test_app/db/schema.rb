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

ActiveRecord::Schema.define(version: 20140411035112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "categories", force: true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "name"
    t.string   "label"
    t.string   "type"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "users_name",   default: "players"
    t.text     "description"
    t.string   "status",       default: "active"
    t.string   "availability", default: "public"
    t.integer  "seq"
    t.string   "slug"
    t.hstore   "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree
  add_index "categories", ["slug"], name: "index_categories_on_slug", unique: true, using: :btree
  add_index "categories", ["type"], name: "index_categories_on_type", using: :btree
  add_index "categories", ["user_id"], name: "index_categories_on_user_id", using: :btree

  create_table "media", force: true do |t|
    t.integer  "user_id"
    t.integer  "managed_by_id"
    t.string   "public_id"
    t.integer  "category_id"
    t.integer  "parent_obj_id"
    t.string   "parent_obj_type"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "type"
    t.string   "sub_type"
    t.string   "title"
    t.string   "subtitle"
    t.string   "avatar"
    t.string   "avatar_caption"
    t.text     "description"
    t.text     "content"
    t.string   "slug"
    t.integer  "reward_threshold",                  default: 100
    t.boolean  "is_commentable",                    default: true
    t.boolean  "is_sticky",                         default: false
    t.boolean  "show_title",                        default: true
    t.datetime "modified_at"
    t.text     "keywords",                          default: [],       array: true
    t.string   "duration"
    t.integer  "price"
    t.integer  "cached_impression_count", limit: 8, default: 0
    t.integer  "cached_comment_count",    limit: 8, default: 0
    t.integer  "cached_vote_count",       limit: 8, default: 0
    t.float    "cached_vote_score",                 default: 0.0
    t.integer  "cached_upvote_count",     limit: 8, default: 0
    t.integer  "cached_downvote_count",   limit: 8, default: 0
    t.float    "score",                             default: 0.0
    t.float    "previous_score",                    default: 0.0
    t.float    "decayed_score",                     default: 0.0
    t.datetime "score_updated_at"
    t.string   "status",                            default: "active"
    t.string   "availability",                      default: "public"
    t.datetime "publish_at"
    t.hstore   "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "media", ["category_id"], name: "index_media_on_category_id", using: :btree
  add_index "media", ["managed_by_id"], name: "index_media_on_managed_by_id", using: :btree
  add_index "media", ["public_id"], name: "index_media_on_public_id", using: :btree
  add_index "media", ["slug", "type"], name: "index_media_on_slug_and_type", using: :btree
  add_index "media", ["slug"], name: "index_media_on_slug", unique: true, using: :btree
  add_index "media", ["status", "availability"], name: "index_media_on_status_and_availability", using: :btree
  add_index "media", ["user_id"], name: "index_media_on_user_id", using: :btree

  create_table "media_thumbnails", force: true do |t|
    t.integer  "media_id"
    t.string   "name"
    t.string   "url"
    t.integer  "height"
    t.integer  "width"
    t.string   "caption"
    t.string   "status",     default: "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "media_thumbnails", ["media_id"], name: "index_media_thumbnails_on_media_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

end
