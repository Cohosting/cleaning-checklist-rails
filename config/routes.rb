Rails.application.routes.draw do
  root "dashboard#index" # Set dashboard as home

  # User authentication
  resource :session, path: "user/signin", only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
  resources :passwords, param: :token

  # Invitations
  resources :invitations, only: [:create] do
    get "accept", on: :collection
    post "accept", on: :collection, to: "invitations#process_accept", as: "process_accept"
  end

  # Properties & Jobs
  resources :properties do
    resources :reservations do
      member do
        get :upsells
      end
    end

    resources :upsells do   
      member do
        post 'checkout'
      end
    end

    patch :make_default_checklist, on: :member
    resources :checklists do
      resources :tasks, only: [:create, :destroy] 
    end
    resources :jobs, only: [:index, :new, :create, :show] do
      resources :job_tasks do
        member do
          delete :remove_image
        end
      end
    end
  end

  # Public job sharing
  resources :job_shares, only: [:show], param: :public_token

  # Webhooks
  post "webhooks/stripe" => "webhooks#stripe"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Mission control
  mount MissionControl::Jobs::Engine, at: "/solid-jobs"
end
