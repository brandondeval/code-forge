class CreateRepositoryBranches < ActiveRecord::Migration[8.0]
  def up
    create_table :repository_branches do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :name, null: false
      t.string :commit_sha, null: false
      t.boolean :protected, null: false, default: false
      t.timestamps
    end
    add_index :repository_branches, %i[repository_id name], unique: true
    execute <<~SQL.squish
      INSERT INTO repository_branches (repository_id, name, commit_sha, protected, created_at, updated_at)
      SELECT id, default_branch, current_commit_sha, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM repositories WHERE current_commit_sha IS NOT NULL
    SQL
  end

  def down
    drop_table :repository_branches
  end
end
