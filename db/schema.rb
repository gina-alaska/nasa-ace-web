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

ActiveRecord::Schema.define(version: 20160907002020) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "maptype"
    t.string   "postfix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "source"
    t.string   "version"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "layers", force: :cascade do |t|
    t.string   "name"
    t.integer  "category_id"
    t.text     "url"
    t.string   "params"
    t.json     "style"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_layers_on_category_id", using: :btree
  end

  create_table "workspace_layers", force: :cascade do |t|
    t.integer  "workspace_id"
    t.integer  "layer_id"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["layer_id"], name: "index_workspace_layers_on_layer_id", using: :btree
    t.index ["workspace_id"], name: "index_workspace_layers_on_workspace_id", using: :btree
  end

  create_table "workspaces", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.decimal  "center_lat", precision: 12, scale: 8
    t.decimal  "center_lng", precision: 12, scale: 8
    t.decimal  "zoom",       precision: 12, scale: 8
  end

  add_foreign_key "layers", "categories"
  add_foreign_key "workspace_layers", "layers"
  add_foreign_key "workspace_layers", "workspaces"
end
