Rails.application.routes.draw do
  post "oauth/register", to: "sessions#register"
  post "oauth/token", to: "sessions#create"
  post "oauth/forgot_password", to: "sessions#forgot_password"
  namespace :api do
    namespace :v1 do
      resource :account, only: :show
      resources :users, param: :login, only: :show
      resources :repository_imports, only: :create
      resources :repositories, param: :name do
        resources :issues, only: %i[index create update]
        resources :pull_requests, only: %i[index create update]
        resource :star, only: %i[create destroy]
      end
    end
  end

  get "component_previews", to: "component_previews#index"
  get "repositories/:owner/:name/file_preview", to: "repositories#file_preview", as: :repository_file_preview
  get "repositories/:owner/:repository_name/commits", to: "repository_commits#index", as: :repository_commits
  get "repositories/:owner/:repository_name/commits/:sha", to: "repository_commit_details#show", as: :repository_commit
  get "repositories/:owner/:repository_name/branches/:branch", to: "repository_branches#show", as: :repository_branch
  get "repositories/:owner/:repository_name/pull_requests/new", to: "repository_pull_requests#new", as: :new_repository_pull_request
  post "repositories/:owner/:repository_name/pull_requests", to: "repository_pull_requests#create", as: :repository_pull_requests
  get "repositories/:owner/:repository_name/pull_requests/:id", to: "repository_pull_requests#show", as: :repository_pull_request
  get "repositories/:owner/:name", to: "repositories#show", as: :repository
  root "component_previews#index"
end
