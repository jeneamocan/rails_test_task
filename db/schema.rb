# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_24_191726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", primary_key: "account_id", force: :cascade do |t|
    t.string "name"
    t.float "balance"
    t.string "currency"
    t.string "nature"
    t.integer "transactions_count"
    t.bigint "login_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["login_id"], name: "index_accounts_on_login_id"
  end

  create_table "customers", primary_key: "customer_id", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
  end

  create_table "logins", primary_key: "login_id", force: :cascade do |t|
    t.string "status"
    t.string "country_code"
    t.string "provider_name"
    t.datetime "last_success_at"
    t.datetime "next_refresh_possible_at"
    t.bigint "customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_logins_on_customer_id"
  end

  create_table "transactions", primary_key: "transaction_id", force: :cascade do |t|
    t.string "status"
    t.string "currency"
    t.float "amount"
    t.string "description"
    t.string "made_on"
    t.string "category"
    t.string "mode"
    t.bigint "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
  end

end
