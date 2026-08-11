class RepositoryCardComponent < ViewComponent::Base
  def initialize(repository:)
    @repository = repository
  end

  def visibility_class
    @repository.visibility == "public" ? "badge--public" : "badge--private"
  end
end
