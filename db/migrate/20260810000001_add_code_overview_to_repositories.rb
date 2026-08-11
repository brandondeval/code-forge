class AddCodeOverviewToRepositories < ActiveRecord::Migration[8.0]
  def up
    add_column :repositories, :default_branch, :string, null: false, default: "main"
    add_column :repositories, :current_commit_sha, :string
    Repository.reset_column_information
    Repository.where(current_commit_sha: nil).find_each { |repository| repository.update_columns(current_commit_sha: SecureRandom.hex(20)) }
  end

  def down
    remove_column :repositories, :current_commit_sha
    remove_column :repositories, :default_branch
  end
end
