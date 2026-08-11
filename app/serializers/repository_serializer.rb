class RepositorySerializer
  def initialize(repository) = @repository = repository
  def as_json(*)
    @repository.as_json(only: %i[id name description visibility stars_count imported_files_count created_at]).merge(
      owner: @repository.owner.slice(:id, :login),
      clone_url: GitRepository.clone_url(@repository),
      open_issues_count: @repository.issues.open.count,
      open_pull_requests_count: @repository.pull_requests.open.count
    )
  end
end
