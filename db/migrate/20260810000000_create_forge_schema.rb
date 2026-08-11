class CreateForgeSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :login, null: false
      t.string :access_token, null: false
      t.timestamps
    end
    add_index :users, :login, unique: true
    add_index :users, :access_token, unique: true
    create_table :repositories do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description
      t.string :visibility, null: false, default: "public"
      t.integer :stars_count, null: false, default: 0
      t.timestamps
    end
    add_index :repositories, :name, unique: true
    create_table :issues do |t|
      t.references :repository, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :body
      t.string :state, null: false, default: "open"
      t.timestamps
    end
    create_table :pull_requests do |t|
      t.references :repository, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :body
      t.string :head_branch, null: false
      t.string :base_branch, null: false
      t.string :state, null: false, default: "open"
      t.timestamps
    end
    create_table :stars do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repository, null: false, foreign_key: true
      t.timestamps
    end
    add_index :stars, %i[user_id repository_id], unique: true
  end
end
