class PullRequestDetailComponent < ViewComponent::Base
  def initialize(repository:, pull_request:)
    @repository = repository
    @pull_request = pull_request
  end

  def state_class
    "state--#{@pull_request.state}"
  end

  def opened_on
    @pull_request.created_at ? @pull_request.created_at.strftime("%b %-d, %Y") : "just now"
  end
end
