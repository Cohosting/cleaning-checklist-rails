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

ActiveRecord::Schema[8.0].define(version: 2025_02_08_103222) do
  create_table "checklists", force: :cascade do |t|
    t.integer "property_id", null: false
    t.string "name", null: false
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_checklists_on_property_id"
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
    t.integer "checklist_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_id"], name: "index_jobs_on_checklist_id"
    t.index ["property_id"], name: "index_jobs_on_property_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_checklist_id"
    t.index ["default_checklist_id"], name: "index_properties_on_default_checklist_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "checklist_id", null: false
    t.string "name", null: false
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_id"], name: "index_tasks_on_checklist_id"
  end

  add_foreign_key "checklists", "properties"
  add_foreign_key "job_tasks", "jobs"
  add_foreign_key "jobs", "checklists"
  add_foreign_key "jobs", "properties"
  add_foreign_key "properties", "checklists", column: "default_checklist_id"
  add_foreign_key "tasks", "checklists"
end
