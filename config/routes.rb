ActionController::Routing::Routes.draw do |map|
  map.resources :user_status_criterions do |user_status_criterion|
    user_status_criterion.resources :fulfillments, :only => [:index]
  end
  map.resources :registration_criterions do |registration_criterion|
    registration_criterion.resources :fulfillments, :only => [:index]
  end
  map.resources :categories
  map.resources :requests, :only => [ :index ]
  map.resources :users, :shallow => true do |user|
    user.resources :addresses
    user.resources :fulfillments, :only => [ :index ]
    user.resources :approvals, :only => [ :index ]
    user.resources :memberships, :only => [ :index, :new, :create ]
  end
  map.resources :approvals, :only => [ :show ]
  map.resources :agreements, :shallow => true do |agreement|
    agreement.resources :approvals, :only => [ :create, :destroy, :index, :new ]
    agreement.resources :fulfillments, :only => [ :index ]
  end
  map.resources :documents, :only => [ :show ]
  map.resources :document_types
  map.resources :requests, :only => [ :index ]
  map.resources :frameworks, :shallow => true do |framework|
    framework.resources :approvers
  end
  map.resources :structures, :shallow => true do |structure|
    structure.resources :nodes
  end
  map.resources :local_event_expenses, :only => [ :index ]
  map.resources :inventory_items, :except => [ :new, :create ],
    :collection => { :retired => :get, :active => :get }
  map.resources :organizations, :member => { :profile => :get }, :shallow => true do |organization|
    organization.resources :inventory_items, :only => [ :index, :new, :create ],
      :collection => { :retired => :get, :active => :get }
    organization.resources :registrations, :only => [ :index ]
    organization.resources :fulfillments, :only => [ :index ]
    organization.resources :bases do |basis|
      basis.resources :requests
    end
    organization.resources :memberships
    organization.resources :requests, :member => { :supporting_documents => :get } do |request|
      request.resources :approvals, :only => [ :create, :destroy, :index, :new ]
      request.resources :items, { :member => { :move => :get, :do_move => :put } } do |item|
        item.resources :editions
      end
    end
  end
  map.resources :roles
  map.resources :registrations, :only => [ :index ] do |registration|
    registration.resources :memberships, :only => [ :index ]
  end
  map.resources :registration_terms, :shallow => true do |term|
    term.resources :registrations, :only => [ :index, :show ] do |registration|
      registration.resource :organization, :only => [ :new, :create ]
    end
  end
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'profile'
  map.unauthorized 'unauthorized', :controller => 'static', :action => 'unauthorized'

  map.resource :user_session
  map.root :controller => "users", :action => "profile" # optional, this just sets the root route

end

