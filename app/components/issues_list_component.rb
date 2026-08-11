class IssuesListComponent < ViewComponent::Base
  def initialize(repository:)
    @repository = repository
  end
end
