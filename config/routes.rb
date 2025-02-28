Rails.application.routes.draw do
  get "section_groups/create"
  get "section_groups/destroy"
  get "section_groups/move"
  get "groups/index"
  get "groups/new"
  get "groups/create"
  get "groups/edit"
  get "groups/update"
  get "groups/destroy"
  get "sections/create"
  get "sections/update"
  get "sections/destroy"
  get "sections/move"
  get "organizations/show"
  root "dashboard#index" # Set dashboard as home
  # Sign-up routes (UsersController)
  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"

  # Sign-in/Sign-out routes (SessionsController)
  get "/signin", to: "sessions#new", as: :signin
  post "/signin", to: "sessions#create"
  delete "/signout", to: "sessions#destroy", as: :signout
  resources :passwords, param: :token

  # Invitations
  resources :invitations, only: [] do
    get :accept, on: :collection
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

  resources :organizations do
    resources :invitations, only: :create
  end
  resources :organizations do
    resources :groups
    
    resources :checklists do
      resources :sections, only: [:create, :edit, :update, :destroy] do
        collection do
          patch :move
        end
        
        resources :section_groups, only: [:create, :edit, :destroy] do
          collection do
            patch :move
          end
          
          member do
            patch :move_to_section 
            get :new_task_form
            get :empty_state  # Add this line for the empty state route
          end
          
          resources :tasks, only: [:create, :update, :edit, :destroy] do
            member do
              patch :toggle
              patch :move
            end
          end
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
