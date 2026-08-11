class RepositoryDetailComponent < ViewComponent::Base
  def initialize(repository:, pull_request:, path: nil, file: nil, branch: nil, tag: nil)
    @repository = repository
    @pull_request = pull_request
    @path = path
    @file = file
    @branch = branch
    @tag = tag
  end

  def status_icon(item)
    item.open? ? "●" : "✓"
  end
end
