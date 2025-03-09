# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_07_112536) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "checklists", force: :cascade do |t|
    t.string "name"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "organization_id", null: false
    t.index ["organization_id"], name: "index_checklists_on_organization_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false
    t.index ["organization_id"], name: "index_groups_on_organization_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "hospitable_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.json "phone_numbers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hospitable_id"], name: "index_guests_on_hospitable_id", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "cleaner", null: false
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "job_tasks", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "name"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_tasks_on_job_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "checklist_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_token"
    t.index ["checklist_id"], name: "index_jobs_on_checklist_id"
    t.index ["property_id"], name: "index_jobs_on_property_id"
    t.index ["public_token"], name: "index_jobs_on_public_token"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "organization_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_checklist_id"
    t.string "hospitable_id"
    t.integer "organization_id", null: false
    t.index ["default_checklist_id"], name: "index_properties_on_default_checklist_id"
    t.index ["hospitable_id"], name: "index_properties_on_hospitable_id", unique: true
    t.index ["organization_id"], name: "index_properties_on_organization_id"
  end

  create_table "property_groups", force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "group_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_property_groups_on_group_id"
    t.index ["property_id"], name: "index_property_groups_on_property_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.string "platform"
    t.string "platform_id"
    t.integer "guest_id", null: false
    t.datetime "booking_date"
    t.datetime "arrival_date"
    t.datetime "departure_date"
    t.integer "nights"
    t.datetime "check_in"
    t.datetime "check_out"
    t.string "status"
    t.decimal "total_price"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "property_id"
    t.string "hospitable_reservation_id"
    t.index ["guest_id"], name: "index_reservations_on_guest_id"
    t.index ["platform_id"], name: "index_reservations_on_platform_id", unique: true
    t.index ["property_id"], name: "index_reservations_on_property_id"
  end

  create_table "section_groups", force: :cascade do |t|
    t.integer "section_id", null: false
    t.integer "group_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_section_groups_on_group_id"
    t.index ["section_id"], name: "index_section_groups_on_section_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "title"
    t.integer "position"
    t.integer "checklist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_id"], name: "index_sections_on_checklist_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content"
    t.integer "position"
    t.integer "section_group_id"
    t.index ["section_group_id"], name: "index_tasks_on_section_group_id"
  end

  create_table "upsell_properties", force: :cascade do |t|
    t.integer "upsell_id", null: false
    t.integer "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_upsell_properties_on_property_id"
    t.index ["upsell_id", "property_id"], name: "index_upsell_properties_on_upsell_id_and_property_id", unique: true
    t.index ["upsell_id"], name: "index_upsell_properties_on_upsell_id"
  end

  create_table "upsells", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "stripe_checkout_session_id"
    t.integer "organization_id", null: false
    t.integer "position"
    t.index ["organization_id"], name: "index_upsells_on_organization_id"
    t.index ["position"], name: "index_upsells_on_position"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "checklists", "organizations"
  add_foreign_key "groups", "organizations"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "job_tasks", "jobs"
  add_foreign_key "jobs", "checklists"
  add_foreign_key "jobs", "properties"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "properties", "checklists", column: "default_checklist_id"
  add_foreign_key "properties", "organizations"
  add_foreign_key "property_groups", "groups"
  add_foreign_key "property_groups", "properties"
  add_foreign_key "reservations", "guests"
  add_foreign_key "reservations", "properties"
  add_foreign_key "section_groups", "groups"
  add_foreign_key "section_groups", "sections"
  add_foreign_key "sections", "checklists"
  add_foreign_key "sessions", "users"
  add_foreign_key "tasks", "section_groups"
  add_foreign_key "upsell_properties", "properties"
  add_foreign_key "upsell_properties", "upsells"
  add_foreign_key "upsells", "organizations"
  add_foreign_key "users", "organizations"
end
