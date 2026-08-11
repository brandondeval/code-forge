class BranchesListComponent < ViewComponent::Base
  def initialize(repository:)
    @repository = repository
  end
end
