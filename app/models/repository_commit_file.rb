class RepositoryCommitFile < ApplicationRecord
  belongs_to :repository_commit
  validates :path, :change_type, presence: true
end
