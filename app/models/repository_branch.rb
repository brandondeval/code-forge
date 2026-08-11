class RepositoryBranch < ApplicationRecord
  belongs_to :repository
  validates :name, :commit_sha, presence: true
  validates :name, uniqueness: { scope: :repository_id }
end
