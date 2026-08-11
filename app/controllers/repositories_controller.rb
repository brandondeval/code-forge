class RepositoriesController < ApplicationController
  def show
    repository = Repository.includes(:owner, issues: :author, pull_requests: :author).joins(:owner).find_by!(name: params[:name], users: { login: params[:owner] })
    # Keep the form object separate: building through the association would add
    # an unsaved item to the pull-request list rendered by the component.
    render RepositoryDetailComponent.new(repository: repository, pull_request: PullRequest.new(repository: repository), path: params[:path], file: params[:file], branch: params[:branch], tag: params[:tag])
  end

  def file_preview
    repository = Repository.includes(:owner).joins(:owner).find_by!(name: params[:name], users: { login: params[:owner] })
    file_path = imported_file_path(repository, params[:file])
    return head :not_found unless file_path

    render FilePreviewComponent.new(repository: repository, path: params[:file], file_path: file_path)
  end

  private

  def imported_file_path(repository, path)
    return unless path.present?
    relative = Pathname.new(path.to_s.tr("\\", "/")).cleanpath.to_s
    return if relative == "." || relative.start_with?("../", "/")
    candidate = Rails.root.join("storage", "repositories", repository.id.to_s, relative)
    candidate.file? ? candidate : nil
  end
end
