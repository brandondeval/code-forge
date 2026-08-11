class Api::V1::StarsController < Api::V1::BaseController
  before_action :require_user!
  before_action :find_repository
  def create
    current_user.stars.find_or_create_by!(repository: @repository)
    render json: RepositorySerializer.new(@repository.reload).as_json
  end
  def destroy
    current_user.stars.find_by(repository: @repository)&.destroy
    render json: RepositorySerializer.new(@repository.reload).as_json
  end
  private
  def find_repository = @repository = Repository.find_by!(name: params[:repository_name])
end
