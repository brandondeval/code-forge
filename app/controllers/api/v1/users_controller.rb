class Api::V1::UsersController < Api::V1::BaseController
  def show
    user = User.includes(:repositories).find_by!(login: params[:login])
    scope = current_user == user ? user.repositories : user.repositories.where(visibility: "public")
    repositories = scope.order(created_at: :desc).map { |repository| RepositorySerializer.new(repository).as_json }
    render json: { user: user.slice(:id, :login, :email), repositories: repositories }
  end
end
