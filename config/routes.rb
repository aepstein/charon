Charon::Application.routes.draw do
  resources :activity_accounts, :except => [ :index, :new, :create ]
  resources :activity_reports, :except => [ :new, :create ]
  resources :addresses, :except => [ :index, :new, :create ]
  resources :agreements do
    resources :approvals, :only => [ :create, :index, :new ]
    resources :fulfillments, :only => [ :index ]
  end
  resources :approvals, :only => [ :show, :destroy ]
  resources :categories
  resources :documents, :only => [ :show ] do
    member do
      get :original
    end
  end
  resources :document_types
  resources :frameworks
  resources :fund_grants, :except => [ :create, :new, :index ] do
    resources :activity_accounts, :only => [ :index, :new, :create ]
    resources :fund_requests, :only => [ :create, :new, :index ]
  end
  resources :fund_editions, :only => [ :destroy ]
  resources :fund_items, :only => [ :destroy ]
  resources :fund_queues, :only => [ :show ] do
    resources :fund_requests, :only => [ :index ] do
      collection do
        get :duplicate, :reviews_report
      end
    end
  end
  resources :fund_request_types
  resources :fund_requests, :except => [ :create, :new ] do
    member do
      get :reject, :documents_report
      put :do_reject, :submit, :withdraw, :reconsider
    end
    resources :approvals, :only => [ :create, :destroy, :index, :new ]
    resources :fund_items, :except => [ :destroy ]
  end
  resources :fund_sources, :except => [ :create, :new ] do
    resources :fund_grants, :only => [ :index ] do
      collection do
        get :released_report
      end
    end
    resources :fund_requests, :only => [ :index ] do
      collection do
        get :unqueued
      end
    end
    resources :fund_tier_assignments, :only => [ :index, :new, :create ]
    resources :organizations, :only => [] do
      collection do
        get :untiered
      end
    end
  end
  resources :fund_tier_assignments, :only => [ :update, :destroy ]
  resources :inventory_items, :except => [ :new, :create ] do
      collection do
        get :retired, :active
      end
  end
  resources :local_event_expenses, :only => [ :index ]
  resources :memberships, :except => [ :create, :new ]
  resources :nodes, :except => [ :index, :create, :new ]
  resources :organizations do
    member do
      get :dashboard
    end
    resources :activity_accounts, :only => [ :index ]
    resources :activity_reports, :only => [ :index, :new, :create ] do
      collection do
        get :past, :current, :future
      end
    end
    resources :fulfillments, :only => [ :index ]
    resources :fund_grants, :only => [ :create, :new, :index ] do
      collection do
        get :closed, :open
      end
    end
    resources :fund_requests, :only => [ :index ] do
      collection do
        get :active, :duplicate, :inactive
      end
    end
    resources :fund_sources, :only => [ :create, :new, :index ]
    resources :inventory_items, :only => [ :index, :new, :create ] do
      collection do
        get :retired, :active
      end
    end
    resources :memberships, :only => [ :create, :new, :index ] do
      collection do
        get :active
      end
    end
    resources :registrations, :only => [ :index ]
    resources :university_accounts, :only => [ :new, :create, :index ]
  end
  resources :registration_criterions do
    resources :fulfillments, :only => [:index]
  end
  resources :registrations, :only => [ :index, :show ] do
    resources :memberships, :only => [ :index, :new, :create ] do
      collection do
        get :active
      end
    end
    resources :organizations, :only => [ :new, :create ]
  end
  resources :registration_terms do
    resources :registrations, :only => [ :index, :show ]
  end
  resources :roles
  resources :structures do
    resources :nodes, :only => [ :index, :create, :new ]
  end
  resources :university_accounts, :except => [ :new, :create ] do
    collection do
      get :activate
      put :do_activate
    end
  end
  resources :user_status_criterions do
    resources :fulfillments, :only => [:index]
  end
  resources :users do
    collection do
      get :admin, :staff
    end
    resources :addresses, :only => [ :index, :new, :create ]
    resources :approvals, :only => [ :index ]
    resources :fulfillments, :only => [ :index ]
    resources :memberships, :only => [ :index, :new, :create ] do
      collection do
        get :active
      end
    end
  end

  resource :user_session

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'profile', :to => 'users#profile', :as => 'profile'

  root :to => 'users#profile'
end

