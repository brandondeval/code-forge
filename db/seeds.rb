ada = User.find_or_initialize_by(login: "ada")
ada.password = ada.password_confirmation = "forge-local-password"
ada.save!
repo = ada.repositories.find_or_create_by!(name: "forge") { |r| r.description = "A GitHub-inspired Rails + React starter." }
repo.issues.find_or_create_by!(author: ada, title: "Welcome to Forge") { |i| i.body = "Create issues and pull requests through the API." }
puts "Seeded user ada — login: ada, password: forge-local-password"
