require "test_helper"

class PullRequestDetailComponentTest < ViewComponent::TestCase
  test "renders pull request details" do
    user = User.new(login: "ada")
    repository = user.repositories.build(name: "forge")
    pull_request = repository.pull_requests.build(author: user, title: "Add a feature", head_branch: "feature", base_branch: "main")
    render_inline(PullRequestDetailComponent.new(repository: repository, pull_request: pull_request))
    assert_text "Add a feature"
    assert_text "feature → main"
  end
end
