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

ActiveRecord::Schema[8.1].define(version: 2026_08_10_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "issues", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "repository_id", null: false
    t.string "state", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_issues_on_author_id"
    t.index ["repository_id"], name: "index_issues_on_repository_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "base_branch", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "head_branch", null: false
    t.bigint "repository_id", null: false
    t.string "state", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_pull_requests_on_author_id"
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_commit_sha"
    t.string "default_branch", default: "main", null: false
    t.text "description"
    t.integer "imported_files_count", default: 0, null: false
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.integer "stars_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "public", null: false
    t.index ["name"], name: "index_repositories_on_name", unique: true
    t.index ["owner_id"], name: "index_repositories_on_owner_id"
  end

  create_table "repository_branches", force: :cascade do |t|
    t.string "commit_sha", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.boolean "protected", default: false, null: false
    t.bigint "repository_id", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id", "name"], name: "index_repository_branches_on_repository_id_and_name", unique: true
    t.index ["repository_id"], name: "index_repository_branches_on_repository_id"
  end

  create_table "repository_commit_files", force: :cascade do |t|
    t.string "change_type", default: "added", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.string "path", null: false
    t.bigint "repository_commit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_commit_id", "path"], name: "index_repository_commit_files_on_repository_commit_id_and_path", unique: true
    t.index ["repository_commit_id"], name: "index_repository_commit_files_on_repository_commit_id"
  end

  create_table "repository_commits", force: :cascade do |t|
    t.string "branch", null: false
    t.datetime "created_at", null: false
    t.string "message", null: false
    t.bigint "repository_id", null: false
    t.string "sha", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id", "sha"], name: "index_repository_commits_on_repository_id_and_sha", unique: true
    t.index ["repository_id"], name: "index_repository_commits_on_repository_id"
  end

  create_table "repository_tags", force: :cascade do |t|
    t.string "commit_sha", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "repository_id", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id", "name"], name: "index_repository_tags_on_repository_id_and_name", unique: true
    t.index ["repository_id"], name: "index_repository_tags_on_repository_id"
  end

  create_table "stars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "repository_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["repository_id"], name: "index_stars_on_repository_id"
    t.index ["user_id", "repository_id"], name: "index_stars_on_user_id_and_repository_id", unique: true
    t.index ["user_id"], name: "index_stars_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "login", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  add_foreign_key "issues", "repositories"
  add_foreign_key "issues", "users", column: "author_id"
  add_foreign_key "pull_requests", "repositories"
  add_foreign_key "pull_requests", "users", column: "author_id"
  add_foreign_key "repositories", "users", column: "owner_id"
  add_foreign_key "repository_branches", "repositories"
  add_foreign_key "repository_commit_files", "repository_commits"
  add_foreign_key "repository_commits", "repositories"
  add_foreign_key "repository_tags", "repositories"
  add_foreign_key "stars", "repositories"
  add_foreign_key "stars", "users"
end
