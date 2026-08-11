class CodeOverviewComponent < ViewComponent::Base
  Entry = Data.define(:name, :path, :directory, :updated_at)

  def initialize(repository:, path: nil, file: nil, branch: nil, tag: nil)
    @repository = repository
    @path = safe_path(path)
    @file = safe_path(file)
    @branch_name = branch
    @tag_name = tag
  end

  def short_sha
    selected_sha&.first(7) || "pending"
  end

  def selected_ref_name
    selected_tag ? selected_tag.name : selected_branch.name
  end

  def selected_tag
    return unless @tag_name.present?
    @selected_tag ||= @repository.repository_tags.find_by(name: @tag_name)
  end

  def selected_branch
    @selected_branch ||= @repository.repository_branches.find_by(name: @branch_name) || @repository.repository_branches.find_by(name: @repository.default_branch)
  end

  def selected_sha
    selected_tag&.commit_sha || selected_branch&.commit_sha || @repository.current_commit_sha
  end

  def branches
    @branches ||= @repository.repository_branches.order(protected: :desc, name: :asc)
  end

  def tags
    @tags ||= @repository.repository_tags.order(name: :asc)
  end

  def entries
    return [] unless directory.exist?

    Dir.children(display_directory).map do |name|
      entry_path = [storage_relative_path, name].reject(&:blank?).join("/")
      absolute_path = display_directory.join(name)
      Entry.new(name, entry_path, absolute_path.directory?, absolute_path.mtime)
    end.sort_by { |entry| [entry.directory ? 0 : 1, entry.name.downcase] }
  end

  def breadcrumbs
    @path.split("/").reject(&:blank?)
  end

  def directory_empty?
    entries.empty?
  end

  def tree_root
    @path.blank? ? display_directory : directory
  end

  def tree_root_path
    @path.blank? ? storage_relative_path : @path
  end

  def tree_empty?
    !tree_root.exist? || Dir.children(tree_root).empty?
  end

  def current_path_label
    @path.presence || "/"
  end

  def parent_directory_path
    return nil if @path.blank?
    parent = File.dirname(@path)
    parent == "." ? nil : parent
  end

  def selected_file
    return unless @file.present?
    candidate = storage_root.join(@file)
    candidate.file? ? candidate : nil
  end

  private

  def storage_root
    Rails.root.join("storage", "repositories", @repository.id.to_s)
  end

  def directory
    candidate = storage_root.join(@path)
    candidate.directory? ? candidate : storage_root
  end

  # Folder-picker and ZIP uploads often wrap every file in one directory named
  # after the project. Treat that wrapper as the repository root.
  def display_directory
    return directory unless @path.blank?
    return directory unless directory.exist?

    children = Dir.children(directory)
    return directory unless children.length == 1

    child = directory.join(children.first)
    child.directory? ? child : directory
  end

  def storage_relative_path
    return @path unless @path.blank? && display_directory != storage_root
    display_directory.relative_path_from(storage_root).to_s
  end

  def ref_params
    selected_tag ? { tag: selected_tag.name } : { branch: selected_branch&.name }
  end

  def safe_path(value)
    path = Pathname.new(value.to_s.tr("\\", "/")).cleanpath.to_s
    return "" if path == "." || path.start_with?("../", "/")
    path
  end
end
