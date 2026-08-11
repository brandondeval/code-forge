class RepositoryCommitDetailsController < ApplicationController
  def show
    repository = Repository.includes(:owner).joins(:owner).find_by!(name: params[:repository_name], users: { login: params[:owner] })
    commit = repository.repository_commits.find_by!(sha: params[:sha])
    render CommitDetailComponent.new(repository: repository, commit: commit)
  end
end
