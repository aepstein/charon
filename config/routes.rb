ActionController::Routing::Routes.draw do |map|
  map.resources :attachment_types
  map.resources :requests, :only => [ :index ]
  map.resources :frameworks, :shallow => true do |framework|
    framework.resources :permissions
  end
  map.resources :approvals, :only => [ :index, :destroy ]
  map.resources :addresses
  map.resources :stages
  map.resources :structures, :shallow => true do |structure|
    structure.resources :nodes
    structure.resources :bases
  end
  map.resources :organizations, :member => { :profile => :get }, :shallow => true do |organization|
    organization.resources :memberships
    organization.resources :requests, :member => { :approve => :post } do |request|
      request.resources :items do |item|
        item.resources :versions do |version|
          version.resources :attachments
      end
    end
  end
  map.resources :roles
  map.resources :users
  map.resources :registrations
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.unauthorized 'unauthorized', :controller => 'static', :action => 'unauthorized'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.resource :user_session
  map.root :controller => "user_sessions", :action => "new" # optional, this just sets the root route

end

