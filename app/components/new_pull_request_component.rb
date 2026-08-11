class NewPullRequestComponent < ViewComponent::Base
  def initialize(repository:, pull_request:)
    @repository = repository
    @pull_request = pull_request
  end
end
