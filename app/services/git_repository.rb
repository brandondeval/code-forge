require "fileutils"

class GitRepository
  ROOT = Pathname.new(ENV.fetch("GIT_ROOT", Rails.root.join("storage", "git").to_s))

  def self.initialize!(repository)
    path = bare_path(repository)
    if path.directory?
      set_default_head(path, repository.default_branch)
      return path
    end

    FileUtils.mkdir_p(path.dirname)
    success = system("git", "init", "--bare", "--initial-branch=#{repository.default_branch}", path.to_s)
    raise "Could not initialize Git repository at #{path}" unless success

    chown_for_git_service(path)
    path
  end

  def self.bare_path(repository)
    ROOT.join(repository.owner.login, "#{repository.name}.git")
  end

  def self.clone_url(repository)
    base = ENV.fetch("GIT_CLONE_BASE_URL", "ssh://forge@localhost:2222")
    "#{base}/#{repository.owner.login}/#{repository.name}.git"
  end

  def self.chown_for_git_service(path)
    return unless Process.uid.zero? && ENV["GIT_SERVICE_UID"].present?
    FileUtils.chown_R(ENV.fetch("GIT_SERVICE_UID").to_i, ENV.fetch("GIT_SERVICE_GID", "1000").to_i, path)
  end

  def self.set_default_head(path, branch)
    system("git", "--git-dir=#{path}", "symbolic-ref", "HEAD", "refs/heads/#{branch}")
  end
end
