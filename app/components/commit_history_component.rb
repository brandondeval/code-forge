class CommitHistoryComponent < ViewComponent::Base
  def initialize(repository:, branch:, commits:)
    @repository = repository
    @branch = branch
    @commits = commits
  end
end
