class CommitDetailComponent < ViewComponent::Base
  FileChange = Data.define(:path, :change_type, :content)

  def initialize(repository:, commit:)
    @repository = repository
    @commit = commit
  end

  def changes
    return @commit.repository_commit_files.order(:path) if @commit.repository_commit_files.any?
    fallback_changes
  end

  def diff_lines(change)
    raw = change.content.to_s.dup.force_encoding("UTF-8")
    return ["Binary file preview is not available."] if change.content == "Binary file" || !raw.valid_encoding? || raw.include?("\u0000")
    raw.lines.presence || [""]
  end

  private

  def fallback_changes
    root = Rails.root.join("storage", "repositories", @repository.id.to_s)
    return [] unless root.directory?
    Dir.glob(root.join("**", "*").to_s).select { |path| File.file?(path) }.map do |path|
      relative = Pathname.new(path).relative_path_from(root).to_s
      FileChange.new(relative, "added", File.binread(path))
    end.sort_by(&:path)
  end
end
