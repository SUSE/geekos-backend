Rails.application.routes.draw do
  root to: 'application#index'

  get '/sessions/init', to: 'sessions#init'
  get '/sessions/login', to: 'sessions#login'

  post "/graphql", to: "graphql#execute"

  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?

  namespace :api do
    resource :search, only: [:show]
    resource :onboarding, only: [:show]
    resource :blog, only: [:show]
    resources :users, only: %i[show update] do
      collection do
        get :search
        get :verify_token
      end
    end
    resources :teams, only: %i[index show update] do
      collection do
        get :root
        get :search
      end
    end
    resources :tags, only: %i[show index update], constraints: { id: /[0-9A-Za-z\_\-.20%]+/ }, format: false do
      get :search, on: :collection
    end

    resources :locations, only: %i[show index] do
      resources :rooms, only: [:show], constraints: { id: /[0-9A-Za-z\-.20%]+/ }, format: false
    end

    get '/meta/users', to: 'meta#users'
    get '/meta/changes', to: 'meta#changes'
  end
end
