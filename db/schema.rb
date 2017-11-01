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

ActiveRecord::Schema.define(version: 20171101025807) do

  create_table "audit_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "user_name"
    t.string "where"
    t.string "ip"
    t.string "user_agent"
    t.text "details"
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "body"
    t.bigint "job_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_comments_on_job_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "contact_firstname"
    t.string "contact_lastname"
    t.string "company_name"
    t.string "email"
    t.string "email2"
    t.string "address"
    t.string "phone_number"
    t.string "phone_number2"
    t.string "fax"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address2"
  end

  create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email_address"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fabrication_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "job_id"
    t.index ["job_id"], name: "index_fabrication_orders_on_job_id"
  end

  create_table "jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "customer_id"
    t.decimal "price", precision: 10
    t.decimal "deposit", precision: 10
    t.string "priority"
    t.string "status", default: "0"
    t.datetime "appointment"
    t.bigint "installer_id"
    t.bigint "salesman_id"
    t.string "duration"
    t.datetime "duedate"
    t.boolean "paid"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude", limit: 24
    t.float "longitude", limit: 24
    t.string "address"
    t.string "address2"
    t.text "notes"
    t.boolean "confirmed_appointment"
    t.index ["customer_id"], name: "index_jobs_on_customer_id"
    t.index ["installer_id"], name: "index_jobs_on_installer_id"
    t.index ["salesman_id"], name: "index_jobs_on_salesman_id"
  end

  create_table "pictures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "image"
    t.bigint "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_pictures_on_job_id"
  end

  create_table "product_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "product_id"
    t.string "status"
    t.string "name"
    t.integer "section_index"
    t.index ["product_id"], name: "index_product_sections_on_product_id"
  end

  create_table "product_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "product_type_id"
    t.string "name"
    t.text "description"
    t.string "status"
    t.string "sku"
    t.integer "price"
    t.bigint "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_index"
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
    t.index ["room_id"], name: "index_products_on_room_id"
  end

  create_table "rooms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.bigint "fabrication_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "master"
    t.integer "room_id"
    t.index ["fabrication_order_id"], name: "index_rooms_on_fabrication_order_id"
  end

  create_table "status_checklist_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "description"
    t.bigint "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status_id"], name: "index_status_checklist_items_on_status_id"
  end

  create_table "statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.datetime "duedate"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude", limit: 24
    t.float "longitude", limit: 24
    t.string "address"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email"
    t.string "crypted_password"
    t.string "salt"
    t.string "first_name"
    t.string "last_name"
    t.string "phonenumber"
    t.string "address"
    t.string "type_of_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "late_access"
    t.text "access_token"
    t.datetime "token_expired"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "working_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "submit_time"
    t.string "submit_method"
    t.string "checkin_or_checkout"
    t.string "submit_date"
    t.string "latitude"
    t.string "longitude"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
  end

  add_foreign_key "comments", "jobs"
  add_foreign_key "comments", "users"
  add_foreign_key "fabrication_orders", "jobs"
  add_foreign_key "jobs", "customers"
  add_foreign_key "jobs", "employees", column: "installer_id"
  add_foreign_key "jobs", "employees", column: "salesman_id"
  add_foreign_key "pictures", "jobs"
  add_foreign_key "product_sections", "products"
  add_foreign_key "products", "product_types"
  add_foreign_key "products", "rooms"
  add_foreign_key "rooms", "fabrication_orders"
  add_foreign_key "status_checklist_items", "statuses"
end
