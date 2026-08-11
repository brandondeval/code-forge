class Api::V1::IssuesController < Api::V1::BaseController
  before_action :find_repository
  before_action :require_user!, only: %i[create update]

  def index
    render json: @repository.issues.includes(:author).order(created_at: :desc)
  end
  def create
    issue = @repository.issues.new(issue_params.merge(author: current_user))
    issue.save ? render(json: issue, status: :created) : render(json: { errors: issue.errors.full_messages }, status: :unprocessable_entity)
  end
  def update
    issue = @repository.issues.find(params[:id])
    issue.update!(params.require(:issue).permit(:title, :body, :state))
    render json: issue
  end
  private
  def find_repository = @repository = Repository.find_by!(name: params[:repository_name])
  def issue_params = params.require(:issue).permit(:title, :body)
end
