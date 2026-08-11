namespace :git do
  desc "Initialize bare Git remotes for all Forge repositories"
  task initialize: :environment do
    Repository.includes(:owner).find_each do |repository|
      GitRepository.initialize!(repository)
      puts "Ready: #{GitRepository.clone_url(repository)}"
    end
  end
end
