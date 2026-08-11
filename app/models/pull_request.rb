class PullRequest < ApplicationRecord
  belongs_to :repository
  belongs_to :author, class_name: "User"
  enum :state, { open: "open", closed: "closed", merged: "merged" }, default: :open
  validates :title, :head_branch, :base_branch, presence: true
end
