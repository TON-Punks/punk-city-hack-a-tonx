require "sidekiq_unique_jobs/web"

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :telegram, controller: :telegram, only: :create
  resources :platformer_games, only: %i[create update]
  resources :zeya_games, only: %i[create update]
  resource :ton_connect, only: %i[show], controller: 'ton_connect'
  resources :lootboxes, only: %i[index show] do
    member do
      post :open
    end
  end

  resources :dao_proposals, only: %i[create index show] do
    resources :votes, controller: :dao_proposal_votes, only: %i[create index]
  end

  resource :admin, only: :show, controller: "admin/home"

  namespace :admin do
    resources :bot_notifications, only: %i[new create]
  end

  namespace :api, defaults: { format: :json } do
    resource :profile, only: :show

    namespace :external do
      resource :stonfi_airdrop, only: :show
    end
    resources :lobby_participants, only: %i[index create] do
      delete :destroy, on: :collection
    end
    resources :rock_paper_scissors_games, only: %i[show create destroy] do
      resources :game_rounds, only: :index do
        post :create, on: :collection
      end
    end

    namespace :inventory do
      resources :weapons, only: [] do
        member do
          post :equip
          post :unequip
        end
      end

      resources :items, only: :index
    end
  end

  require "sidekiq/web"
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest("")) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password),
          ::Digest::SHA256.hexdigest(""))
    end
  end
  mount Sidekiq::Web, at: "/sidekiq"
end
