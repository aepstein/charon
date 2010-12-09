Charon::Application.routes.draw do
  shallow do
    resources :activity_reports, :except => [ :new, :create ]
    resources :university_accounts, :except => [ :new, :create ]
    resources :user_status_criterions do
      resources :fulfillments, :only => [:index]
    end
    resources :registration_criterions do
      resources :fulfillments, :only => [:index]
    end
    resources :categories
    resources :requests, :only => [ :index ]
    resources :users do
      resources :addresses
      resources :fulfillments, :only => [ :index ]
      resources :approvals, :only => [ :index ]
      resources :memberships, :only => [ :index, :new, :create ]
    end
    resources :approvals, :only => [ :show ]
    resources :agreements do
      resources :approvals, :only => [ :create, :destroy, :index, :new ]
      resources :fulfillments, :only => [ :index ]
    end
    resources :documents, :only => [ :show ]
    resources :document_types
    resources :requests, :only => [ :index ]
    resources :frameworks do
      resources :approvers
    end
    resources :structures do
      resources :nodes
    end
    resources :local_event_expenses, :only => [ :index ]
    resources :inventory_items, :except => [ :new, :create ] do
        collection do
          get :retired, :active
        end
    end
    resources :organizations do
      member do
        get :profile
      end
      resources :activity_reports, :only => [ :index, :new, :create ] do
        collection do
          get :past, :current, :future
        end
      end
      resources :university_accounts, :only => [ :new, :create, :index ]
      resources :inventory_items, :only => [ :index, :new, :create ] do
        collection do
          get :retired, :active
        end
      end
      resources :registrations, :only => [ :index ]
      resources :fulfillments, :only => [ :index ]
      resources :bases do
        resources :requests
      end
      resources :memberships
      resources :requests do
        collection do
          get :supporting_documents
        end
        resources :approvals, :only => [ :create, :destroy, :index, :new ]
        resources :items do
          collection do
            get :move
            put :do_move
          end
          resources :editions
        end
      end
    end
    resources :roles
    resources :registrations, :only => [ :index ] do
      resources :memberships, :only => [ :index ]
    end
    resources :registration_terms do
      resources :registrations, :only => [ :index, :show ] do
        resource :organization, :only => [ :new, :create ]
      end
    end
  end

  resource :user_session

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'profile', :to => 'users#profile', :as => 'profile'

  root :to => 'users#profile'
end

