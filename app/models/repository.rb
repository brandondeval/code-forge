class Repository < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :issues, dependent: :destroy
  has_many :pull_requests, dependent: :destroy
  has_many :stars, dependent: :destroy
  has_many :repository_commits, dependent: :destroy
  has_many :repository_branches, dependent: :destroy
  has_many :repository_tags, dependent: :destroy
  validates :visibility, inclusion: { in: %w[public private] }
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9._-]+\z/ }
  before_validation :set_code_defaults, on: :create
  after_create :record_initial_commit
  after_create :record_default_branch
  after_create :record_initial_tag
  after_create :initialize_git_remote

  private

  def set_code_defaults
    self.default_branch ||= "main"
    self.current_commit_sha ||= SecureRandom.hex(20)
  end

  def record_initial_commit
    repository_commits.create!(sha: current_commit_sha, branch: default_branch, message: "Initial repository commit")
  end

  def record_default_branch
    repository_branches.create!(name: default_branch, commit_sha: current_commit_sha, protected: true)
  end

  def record_initial_tag
    repository_tags.create!(name: "initial", commit_sha: current_commit_sha)
  end

  def initialize_git_remote
    GitRepository.initialize!(self)
  end
end
