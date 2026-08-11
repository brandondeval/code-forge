class RepositoryCommitsController < ApplicationController
  def index
    @repository = Repository.includes(:owner).joins(:owner).find_by!(name: params[:repository_name], users: { login: params[:owner] })
    @branch = params[:branch].presence || @repository.default_branch
    @commits = @repository.repository_commits.where(branch: @branch).order(created_at: :desc)
    render CommitHistoryComponent.new(repository: @repository, branch: @branch, commits: @commits)
  end
end
