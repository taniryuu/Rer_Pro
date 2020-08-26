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

ActiveRecord::Schema.define(version: 2020_08_19_222355) do

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "admin", default: false, null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string "created_date", default: "", null: false
    t.string "completed_date", default: "", null: false
    t.string "customer_name", default: "", null: false
    t.string "room_name", default: "", null: false
    t.string "room_num", default: "", null: false
    t.boolean "template", default: false, null: false
    t.string "template_name", default: "", null: false
    t.string "memo", default: "", null: false
    t.integer "status", default: 0, null: false
    t.boolean "notice_created", default: true, null: false
    t.boolean "notice_change_limit", default: false, null: false
    t.string "scheduled_resident_date", default: "", null: false
    t.string "scheduled_payment_date", default: "", null: false
    t.string "scheduled_contract_date", default: "", null: false
    t.integer "steps_rate", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "login_id"
    t.boolean "superior", default: false
    t.boolean "admin", default: false
    t.integer "superior_id"
    t.integer "lead_count", default: 0
    t.integer "lead_count_delay", default: 0
    t.integer "notified_num", default: 3
    t.integer "status", default: 0
    t.integer "company_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
