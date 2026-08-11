require "test_helper"

class RepositoryCardComponentTest < ViewComponent::TestCase
  test "renders repository metadata" do
    user = User.new(login: "ada")
    repository = user.repositories.build(name: "forge", description: "A starter", stars_count: 3)
    render_inline(RepositoryCardComponent.new(repository: repository))
    assert_text "ada/forge"
    assert_text "★ 3"
  end
end
