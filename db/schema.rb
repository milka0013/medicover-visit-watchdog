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

ActiveRecord::Schema.define(version: 20150213012714) do

  create_table "medicover_visit_queries", force: :cascade do |t|
    t.integer  "region"
    t.integer  "booking_type"
    t.integer  "specialization"
    t.integer  "clinic"
    t.integer  "language"
    t.integer  "doctor"
    t.datetime "search_since"
    t.datetime "search_for_next_since"
    t.integer  "period_of_the_day"
    t.boolean  "set_because_of_pcc"
    t.boolean  "is_set_because_promote_specialization"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

end