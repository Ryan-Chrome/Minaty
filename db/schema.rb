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

ActiveRecord::Schema.define(version: 2021_05_08_092402) do

  create_table "attendances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "arrived_at"
    t.datetime "left_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "work_on", null: false
    t.index ["user_id", "work_on"], name: "index_attendances_on_user_id_and_work_on", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "contact_group_relations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "contact_group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contact_group_id"], name: "index_contact_group_relations_on_contact_group_id"
    t.index ["user_id", "contact_group_id"], name: "index_contact_group_relations_on_user_id_and_contact_group_id", unique: true
    t.index ["user_id"], name: "index_contact_group_relations_on_user_id"
  end

  create_table "contact_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_contact_groups_on_user_id"
  end

  create_table "entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "meeting_room_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meeting_room_id"], name: "index_entries_on_meeting_room_id"
    t.index ["user_id", "meeting_room_id"], name: "index_entries_on_user_id_and_meeting_room_id", unique: true
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "general_message_relations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "receive_user_id", null: false
    t.bigint "general_message_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["general_message_id"], name: "index_general_message_relations_on_general_message_id"
    t.index ["receive_user_id", "general_message_id"], name: "index_general_message_user_message", unique: true
    t.index ["receive_user_id"], name: "index_general_message_relations_on_receive_user_id"
    t.index ["user_id"], name: "index_general_message_relations_on_user_id"
  end

  create_table "general_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "room_id"
    t.index ["user_id"], name: "index_general_messages_on_user_id"
  end

  create_table "meeting_rooms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_at"
    t.datetime "finish_at"
    t.string "public_uid"
    t.text "comment"
    t.index ["public_uid"], name: "index_meeting_rooms_on_public_uid", unique: true
  end

  create_table "paid_holidays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "holiday_on"
    t.text "reason"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "holiday_on"], name: "index_paid_holidays_on_user_id_and_holiday_on", unique: true
    t.index ["user_id"], name: "index_paid_holidays_on_user_id"
  end

  create_table "room_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "meeting_room_id", null: false
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meeting_room_id"], name: "index_room_messages_on_meeting_room_id"
    t.index ["user_id"], name: "index_room_messages_on_user_id"
  end

  create_table "schedules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "start_at"
    t.string "finish_at"
    t.date "work_on"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "department"
    t.string "public_uid"
    t.boolean "admin", default: false
    t.string "kana"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["public_uid"], name: "index_users_on_public_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "contact_group_relations", "contact_groups"
  add_foreign_key "contact_group_relations", "users"
  add_foreign_key "contact_groups", "users"
  add_foreign_key "entries", "meeting_rooms"
  add_foreign_key "entries", "users"
  add_foreign_key "general_message_relations", "general_messages"
  add_foreign_key "general_message_relations", "users"
  add_foreign_key "general_message_relations", "users", column: "receive_user_id"
  add_foreign_key "general_messages", "users"
  add_foreign_key "paid_holidays", "users"
  add_foreign_key "room_messages", "meeting_rooms"
  add_foreign_key "room_messages", "users"
  add_foreign_key "schedules", "users"
end
