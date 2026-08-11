class RepositoryPullRequestsController < ApplicationController
  def new
    repository = find_repository
    pull_request = PullRequest.new(repository: repository, head_branch: params[:head_branch])
    render NewPullRequestComponent.new(repository: repository, pull_request: pull_request)
  end

  def show
    repository = find_repository
    pull_request = repository.pull_requests.includes(:author).find(params[:id])
    render PullRequestDetailComponent.new(repository: repository, pull_request: pull_request)
  end

  def create
    repository = find_repository
    author = user_from_token(params[:access_token])
    pull_request = PullRequest.new(pull_request_params.merge(repository: repository))
    pull_request.author = author if author

    if author && pull_request.save
      redirect_to repository_path(repository.owner.login, repository.name), notice: "Pull request created."
    else
      pull_request.errors.add(:base, "Access token is invalid") unless author
      render RepositoryDetailComponent.new(repository: repository, pull_request: pull_request), status: :unprocessable_entity
    end
  end

  private

  def pull_request_params
    params.require(:pull_request).permit(:title, :body, :head_branch, :base_branch)
  end

  def find_repository
    Repository.includes(:owner, issues: :author, pull_requests: :author).joins(:owner).find_by!(name: params[:repository_name], users: { login: params[:owner] })
  end
end
