class CreateRepositoryTags < ActiveRecord::Migration[8.0]
  def up
    create_table :repository_tags do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :name, null: false
      t.string :commit_sha, null: false
      t.timestamps
    end
    add_index :repository_tags, %i[repository_id name], unique: true
    execute <<~SQL.squish
      INSERT INTO repository_tags (repository_id, name, commit_sha, created_at, updated_at)
      SELECT id, 'initial', current_commit_sha, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM repositories WHERE current_commit_sha IS NOT NULL
    SQL
  end

  def down
    drop_table :repository_tags
  end
end
