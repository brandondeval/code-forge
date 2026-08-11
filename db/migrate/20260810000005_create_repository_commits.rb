class CreateRepositoryCommits < ActiveRecord::Migration[8.0]
  def up
    create_table :repository_commits do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :sha, null: false
      t.string :branch, null: false
      t.string :message, null: false
      t.timestamps
    end
    add_index :repository_commits, %i[repository_id sha], unique: true
    execute <<~SQL.squish
      INSERT INTO repository_commits (repository_id, sha, branch, message, created_at, updated_at)
      SELECT id, current_commit_sha, default_branch, 'Initial repository commit', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM repositories
      WHERE current_commit_sha IS NOT NULL
    SQL
  end

  def down
    drop_table :repository_commits
  end
end
