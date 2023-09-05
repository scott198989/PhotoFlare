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

ActiveRecord::Schema[7.0].define(version: 2022_10_07_133604) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.text "name"
    t.text "record_type"
    t.bigint "record_id"
    t.bigint "blob_id"
    t.timestamptz "created_at"
    t.index ["blob_id"], name: "idx_25028_index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "idx_25028_index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.text "key"
    t.text "filename"
    t.text "content_type"
    t.text "metadata"
    t.text "service_name"
    t.bigint "byte_size"
    t.text "checksum"
    t.timestamptz "created_at"
    t.index ["key"], name: "idx_25021_index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id"
    t.text "variation_digest"
    t.index ["blob_id", "variation_digest"], name: "idx_25035_index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "post_id"
    t.text "body"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["post_id"], name: "idx_25047_index_comments_on_post_id"
    t.index ["user_id"], name: "idx_25047_index_comments_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id"
    t.bigint "followed_id"
    t.boolean "accepted", default: false
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["followed_id"], name: "idx_25054_index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "idx_25054_index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "idx_25054_index_follows_on_follower_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "post_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["post_id"], name: "idx_25042_index_likes_on_post_id"
    t.index ["user_id", "post_id"], name: "idx_25042_index_likes_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "idx_25042_index_likes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "caption"
    t.float "longitude"
    t.float "latitude"
    t.bigint "user_id"
    t.boolean "allow_comments"
    t.boolean "show_likes_count"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["user_id"], name: "idx_25014_index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "email", default: ""
    t.text "encrypted_password", default: ""
    t.text "full_name"
    t.text "username"
    t.text "phone_number"
    t.text "reset_password_token"
    t.timestamptz "reset_password_sent_at"
    t.timestamptz "remember_created_at"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "bio"
    t.boolean "private", default: true
    t.index ["email"], name: "idx_25004_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "idx_25004_index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", name: "active_storage_attachments_blob_id_fkey"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", name: "active_storage_variant_records_blob_id_fkey"
  add_foreign_key "comments", "posts", name: "comments_post_id_fkey"
  add_foreign_key "comments", "users", name: "comments_user_id_fkey"
  add_foreign_key "likes", "posts", name: "likes_post_id_fkey"
  add_foreign_key "likes", "users", name: "likes_user_id_fkey"
  add_foreign_key "posts", "users", name: "posts_user_id_fkey"
end
