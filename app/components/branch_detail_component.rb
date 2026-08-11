class BranchDetailComponent < ViewComponent::Base
  def initialize(repository:, branch:, commits:)
    @repository = repository
    @branch = branch
    @commits = commits
  end

  def default_branch?
    @branch.name == @repository.default_branch
  end
end
