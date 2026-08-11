class FileTreeComponent < ViewComponent::Base
  Entry = Data.define(:name, :path, :directory, :updated_at)

  def initialize(repository:, directory:, path: "", depth: 0, ref_params: {})
    @repository = repository
    @directory = directory
    @path = path
    @depth = depth
    @ref_params = ref_params
  end

  def entries
    Dir.children(@directory).map do |name|
      path = [@path, name].reject(&:blank?).join("/")
      absolute_path = @directory.join(name)
      Entry.new(name, path, absolute_path.directory?, absolute_path.mtime)
    end.sort_by { |entry| [entry.directory ? 0 : 1, entry.name.downcase] }
  end

  def child_directory(entry)
    @directory.join(entry.name)
  end
end
