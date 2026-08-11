class RepositoryCommit < ApplicationRecord
  belongs_to :repository
  has_many :repository_commit_files, dependent: :destroy
  validates :sha, :branch, :message, presence: true
end
