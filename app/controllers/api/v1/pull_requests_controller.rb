class Api::V1::PullRequestsController < Api::V1::BaseController
  before_action :find_repository
  before_action :require_user!, only: %i[create update]
  def index = render json: @repository.pull_requests.includes(:author).order(created_at: :desc)
  def create
    pull_request = @repository.pull_requests.new(pull_request_params.merge(author: current_user))
    pull_request.save ? render(json: pull_request, status: :created) : render(json: { errors: pull_request.errors.full_messages }, status: :unprocessable_entity)
  end
  def update
    pull_request = @repository.pull_requests.find(params[:id])
    pull_request.update!(params.require(:pull_request).permit(:title, :body, :state))
    render json: pull_request
  end
  private
  def find_repository = @repository = Repository.find_by!(name: params[:repository_name])
  def pull_request_params = params.require(:pull_request).permit(:title, :body, :head_branch, :base_branch)
end
