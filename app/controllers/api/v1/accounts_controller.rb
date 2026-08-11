class Api::V1::AccountsController < Api::V1::BaseController
  before_action :require_user!

  def show
    repositories = current_user.repositories.order(created_at: :desc).map { |repository| RepositorySerializer.new(repository).as_json }
    render json: { user: current_user.slice(:id, :login, :email), repositories: repositories }
  end
end
