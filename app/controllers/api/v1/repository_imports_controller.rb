require "fileutils"
require "pathname"
require "zip"

class Api::V1::RepositoryImportsController < Api::V1::BaseController
  before_action :require_user!

  def create
    repository = current_user.repositories.new(repository_params)
    files = Array(params[:files])
    paths = Array(params[:paths])
    archive = params[:archive]
    return render(json: { errors: ["Choose a repository folder or ZIP archive"] }, status: :unprocessable_entity) if files.empty? && archive.blank?

    if repository.save
      destination = Rails.root.join("storage", "repositories", repository.id.to_s)
      imported_count = archive.present? ? extract_archive(archive, destination) : copy_files(files, paths, destination)
      repository.update!(imported_files_count: imported_count)
      record_import_commit(repository, destination)
      render json: RepositorySerializer.new(repository).as_json, status: :created
    else
      render json: { errors: repository.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ArgumentError => error
    repository&.destroy
    render json: { errors: [error.message] }, status: :unprocessable_entity
  end

  private

  def repository_params
    params.require(:repository).permit(:name, :description, :visibility)
  end

  def safe_relative_path(value)
    path = Pathname.new(value.to_s.tr("\\", "/")).cleanpath.to_s
    raise ArgumentError, "Invalid file path" if path.blank? || path.start_with?("../", "/") || path == "."
    path
  end

  def copy_files(files, paths, destination)
    cleaned_paths = strip_common_root(files.each_with_index.map { |file, index| paths[index].presence || file.original_filename })
    files.each_with_index do |file, index|
      write_file(destination, cleaned_paths[index], file.read)
    end.length
  end

  def extract_archive(archive, destination)
    raise ArgumentError, "Only .zip archives are supported" unless archive.original_filename.downcase.end_with?(".zip")

    count = 0
    Zip::File.open(archive.tempfile) do |zip|
      files = zip.reject(&:directory?)
      cleaned_paths = strip_common_root(files.map(&:name))
      files.each_with_index do |entry, index|
        write_file(destination, cleaned_paths[index], entry.get_input_stream.read)
        count += 1
      end
    end
    raise ArgumentError, "The ZIP archive does not contain any files" if count.zero?
    count
  end

  def write_file(destination, path, content)
    target = destination.join(safe_relative_path(path))
    FileUtils.mkdir_p(target.dirname)
    File.binwrite(target, content)
  end

  def strip_common_root(paths)
    root = paths.map { |path| path.to_s.tr("\\", "/").split("/").first }.uniq
    return paths unless root.one? && paths.all? { |path| path.to_s.tr("\\", "/").include?("/") }

    prefix = "#{root.first}/"
    paths.map { |path| path.to_s.tr("\\", "/").delete_prefix(prefix) }
  end

  def record_import_commit(repository, destination)
    sha = SecureRandom.hex(20)
    repository.update!(current_commit_sha: sha)
    repository.repository_branches.find_by(name: repository.default_branch)&.update!(commit_sha: sha)
    commit = repository.repository_commits.create!(sha: sha, branch: repository.default_branch, message: "Import repository files")
    Dir.glob(destination.join("**", "*").to_s).select { |path| File.file?(path) }.each do |path|
      relative_path = Pathname.new(path).relative_path_from(destination).to_s
      content = File.binread(path)
      text = content.dup.force_encoding("UTF-8")
      commit.repository_commit_files.create!(path: relative_path, change_type: "added", content: text.valid_encoding? ? text : "Binary file")
    end
  end
end
