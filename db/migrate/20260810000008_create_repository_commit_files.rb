class CreateRepositoryCommitFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :repository_commit_files do |t|
      t.references :repository_commit, null: false, foreign_key: true
      t.string :path, null: false
      t.string :change_type, null: false, default: "added"
      t.text :content
      t.timestamps
    end
    add_index :repository_commit_files, %i[repository_commit_id path], unique: true
  end
end
