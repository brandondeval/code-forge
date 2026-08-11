class Api::V1::RepositoriesController < Api::V1::BaseController
  before_action :require_user!, only: :create
  before_action :find_repository, only: :show

  def index
    render json: Repository.includes(:owner).order(stars_count: :desc).map { |repo| RepositorySerializer.new(repo).as_json }
  end

  def show
    render json: RepositorySerializer.new(@repository).as_json
  end

  def create
    repository = current_user.repositories.new(repository_params)
    if repository.save
      render json: RepositorySerializer.new(repository).as_json, status: :created
    else
      render json: { errors: repository.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def find_repository = @repository = Repository.find_by!(name: params[:name])
  def repository_params = params.require(:repository).permit(:name, :description, :visibility)
end
