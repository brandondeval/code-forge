require "diff/lcs"

class PullRequestDiffComponent < ViewComponent::Base
  Change = Data.define(:path, :before, :after)

  def initialize(repository:, pull_request:)
    @repository = repository
    @pull_request = pull_request
  end

  def changes
    @changes ||= begin
      base = files_for(latest_commit(@pull_request.base_branch), @pull_request.base_branch)
      head = files_for(latest_commit(@pull_request.head_branch), @pull_request.head_branch)
      (base.keys | head.keys).sort.filter_map do |path|
        before, after = base[path].to_s, head[path].to_s
        Change.new(path, before, after) unless before == after
      end
    end
  end

  def diff_lines(change)
    Diff::LCS.diff(change.before.lines, change.after.lines).flat_map do |piece|
      piece.map { |line| [line.action, line.element.to_s] }
    end
  end

  def change_label(change)
    return "added" if change.before.empty?
    return "deleted" if change.after.empty?
    "changed"
  end

  private

  def latest_commit(branch)
    @repository.repository_commits.where(branch: branch).order(created_at: :desc).first
  end

  def files_for(commit, branch)
    if commit&.repository_commit_files&.any?
      commit.repository_commit_files.to_h { |file| [file.path, file.content] }
    elsif branch == @repository.default_branch
      storage_files
    else
      {}
    end
  end

  def storage_files
    root = Rails.root.join("storage", "repositories", @repository.id.to_s)
    return {} unless root.directory?
    Dir.glob(root.join("**", "*").to_s).select { |path| File.file?(path) }.to_h do |path|
      raw = File.binread(path).force_encoding("UTF-8")
      [Pathname.new(path).relative_path_from(root).to_s, raw.valid_encoding? ? raw : "Binary file"]
    end
  end
end
