Charon::Application.routes.draw do
  resources :activity_accounts, :except => [ :index, :new, :create ]
  resources :activity_reports, :except => [ :new, :create ]
  resources :addresses, :except => [ :index, :new, :create ]
  resources :agreements do
    resources :approvals, :only => [ :create, :index, :new ]
    resources :fulfillments, :only => [ :index ]
  end
  resources :approvals, :only => [ :show, :destroy ]
  resources :approvers, :except => [ :index, :create, :new ]
  resources :fund_sources, :except => [ :create, :new ] do
    resources :fund_requests, :only => [ :create, :new, :index ] do
      collection do
        get :duplicate
      end
    end
  end
  resources :categories
  resources :documents, :only => [ :show ] do
    member do
      get :original
    end
  end
  resources :document_types
  resources :frameworks do
    resources :approvers, :only => [ :index, :create, :new ]
  end
  resources :inventory_fund_items, :except => [ :new, :create ] do
      collection do
        get :retired, :active
      end
  end
  resources :fund_items, :except => [ :create, :new, :index ]
  resources :local_event_expenses, :only => [ :index ]
  resources :memberships, :except => [ :create, :new ]
  resources :nodes, :except => [ :index, :create, :new ]
  resources :organizations do
    member do
      get :profile
    end
    resources :activity_accounts, :only => [ :index ]
    resources :activity_reports, :only => [ :index, :new, :create ] do
      collection do
        get :past, :current, :future
      end
    end
    resources :fund_sources, :only => [ :create, :new, :index ]
    resources :fulfillments, :only => [ :index ]
    resources :inventory_fund_items, :only => [ :index, :new, :create ] do
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
    resources :fund_requests, :only => [ :create, :new, :index ] do
      collection do
        get :duplicate
      end
    end
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
  resources :fund_requests, :except => [ :create, :new ] do
    member do
      get :reject, :documents_report
      put :do_reject
      put :accept
    end
    collection do
      get :duplicate
    end
    resources :approvals, :only => [ :create, :destroy, :index, :new ]
    resources :fund_items, :only => [ :create, :new, :index ]
  end
  resources :roles
  resources :structures do
    resources :nodes, :only => [ :index, :create, :new ]
  end
  resources :university_accounts, :except => [ :new, :create ] do
    resources :activity_accounts, :only => [ :index, :new, :create ]
  end
  resources :user_status_criterions do
    resources :fulfillments, :only => [:index]
  end
  resources :users do
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

