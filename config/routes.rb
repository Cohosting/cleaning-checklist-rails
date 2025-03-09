Rails.application.routes.draw do
  root "dashboard#index" # Set dashboard as home

  # User Authentication
  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"
  get "/signin", to: "sessions#new", as: :signin
  post "/signin", to: "sessions#create"
  delete "/signout", to: "sessions#destroy", as: :signout

  # Password reset
  resources :passwords, param: :token

  # Invitations
  resources :invitations, only: [] do
    get :accept, on: :collection
  end

  # Organizations & Related Models
  resources :organizations do
    resources :invitations, only: :create

    # checklists

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
            get :empty_state
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



    resources :properties do
      resources :reservations do
        member do
          get :upsells
        end


      end

      resources :property_groups, only: [:new, :create, :destroy]



      patch :make_default_checklist, on: :member
      resources :jobs, only: [:index, :new, :create, :show] do
        resources :job_tasks do
          member do
            delete :remove_image
          end
        end
      end
    end

    # Groups
    resources :groups

    # Upsells
    resources :upsells do
      collection do
        patch :reorder
      end
        
        member do
        post :checkout
        get :edit_properties
        patch :update_properties
      end
    end


  end

  # Public Job Sharing
  resources :job_shares, only: [:show], param: :public_token

  # Webhooks
  post "webhooks/stripe" => "webhooks#stripe"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # Mission Control
  mount MissionControl::Jobs::Engine, at: "/solid-jobs"
end
