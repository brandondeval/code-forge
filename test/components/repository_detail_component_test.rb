require "test_helper"

class RepositoryDetailComponentTest < ViewComponent::TestCase
  test "renders repository details" do
    user = User.new(login: "ada")
    repository = user.repositories.build(name: "forge", description: "A starter", stars_count: 2)
    render_inline(RepositoryDetailComponent.new(repository: repository, pull_request: PullRequest.new(repository: repository)))
    assert_text "ada / forge"
    assert_text "★ 2 stars"
    assert_text "Open a pull request"
  end
end
