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

ActiveRecord::Schema.define(version: 20180620192640) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "maptype"
    t.string "postfix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "source"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "layers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "category_id"
    t.text "url"
    t.string "params"
    t.json "style"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ckan_id"
    t.index ["category_id"], name: "index_layers_on_category_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.string "ckan_api_key"
    t.string "fullname"
    t.string "email"
    t.string "group"
    t.boolean "sysadmin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "view_layers", id: :serial, force: :cascade do |t|
    t.integer "view_id"
    t.integer "layer_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.index ["layer_id"], name: "index_view_layers_on_layer_id"
    t.index ["view_id"], name: "index_view_layers_on_view_id"
  end

  create_table "views", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "center_lat", precision: 12, scale: 8
    t.decimal "center_lng", precision: 12, scale: 8
    t.decimal "zoom", precision: 12, scale: 8
    t.string "presenter_id"
    t.string "basemap"
    t.integer "workspace_id"
    t.boolean "view_3d_mode", default: false
    t.index ["workspace_id"], name: "index_views_on_workspace_id"
  end

  create_table "workspaces", id: :serial, force: :cascade do |t|
    t.string "name"
  end

  add_foreign_key "layers", "categories"
  add_foreign_key "view_layers", "layers"
  add_foreign_key "view_layers", "views"
  add_foreign_key "views", "workspaces"
end
