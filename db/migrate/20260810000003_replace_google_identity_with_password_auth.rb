class ReplaceGoogleIdentityWithPasswordAuth < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, column: %i[provider uid]
    remove_columns :users, :provider, :uid, :name, :avatar_url, :access_token
    add_column :users, :password_digest, :string, null: false, default: ""
  end
end
