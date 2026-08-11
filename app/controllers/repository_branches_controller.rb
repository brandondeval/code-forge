class RepositoryBranchesController < ApplicationController
  def show
    repository = Repository.includes(:owner).joins(:owner).find_by!(name: params[:repository_name], users: { login: params[:owner] })
    branch = repository.repository_branches.find_by!(name: params[:branch])
    commits = repository.repository_commits.where(branch: branch.name).order(created_at: :desc)
    render BranchDetailComponent.new(repository: repository, branch: branch, commits: commits)
  end
end
