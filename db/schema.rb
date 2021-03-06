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

ActiveRecord::Schema.define(version: 20151019154839) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "domain"
  end

  create_table "auth_objects", force: :cascade do |t|
    t.string   "user_token"
    t.string   "permissions"
    t.integer  "content_id"
    t.string   "content_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "application_id"
    t.string   "token"
  end

  add_index "auth_objects", ["application_id"], name: "index_auth_objects_on_application_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "auth_objects", "applications", on_delete: :cascade
end
