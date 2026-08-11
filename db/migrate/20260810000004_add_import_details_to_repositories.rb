class AddImportDetailsToRepositories < ActiveRecord::Migration[8.0]
  def change
    add_column :repositories, :imported_files_count, :integer, null: false, default: 0
  end
end
