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

ActiveRecord::Schema.define(version: 20150406171922) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "days", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id",                                              null: false
    t.date     "date",                                                 null: false
    t.string   "month_number",                                         null: false
    t.string   "week_number",                                          null: false
    t.decimal  "client_hours",   precision: 4, scale: 2, default: 0.0, null: false
    t.decimal  "internal_hours", precision: 4, scale: 2, default: 0.0, null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "days", ["date"], name: "index_days_on_date", using: :btree
  add_index "days", ["month_number"], name: "index_days_on_month_number", using: :btree
  add_index "days", ["user_id"], name: "index_days_on_user_id", using: :btree
  add_index "days", ["week_number"], name: "index_days_on_week_number", using: :btree

  create_table "months", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id",                                              null: false
    t.string   "number",                                               null: false
    t.decimal  "client_hours",   precision: 5, scale: 2, default: 0.0, null: false
    t.decimal  "internal_hours", precision: 5, scale: 2, default: 0.0, null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "months", ["number"], name: "index_months_on_number", using: :btree
  add_index "months", ["user_id"], name: "index_months_on_user_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "email",         null: false
    t.string   "harvest_id",    null: false
    t.string   "zenefits_name", null: false
    t.string   "time_zone",     null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
