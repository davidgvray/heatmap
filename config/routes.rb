ActionController::Routing::Routes.draw do |map|
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
  
  map.connect '/l', :controller => "logs", :action => "script"
  
  map.resources :pages, :only => :show
  
  map.resources :logs, :only => :create
  
  map.resources :videos
  
  map.resources :users, :only => [:new, :create]
  
  map.resource :user, :only => [:edit, :update, :destroy]
  
  map.resources :password_resets, :except => :destroy
  
  map.resource :user_session
  
  map.resource :dashboard, :only => :show
  
  map.account 'account', :controller => 'users', :action => 'edit'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.signup 'signup', :controller => 'users', :action => 'new'
  
  
  map.root :controller => 'home'
  map.home ':page', :controller => 'home', :action => 'show', :page => /index.html|about.html|contact.html|test.html|blog.html|hq.html|pricing.html|signup.html|apps.html|products.html|services.html|single.html|tour.html|webdesign.html|index.htm|elements.html|privacy.html|library.html|features.html|testimonials.html|irb.html/                          
  
  
  map.username ':username', :controller => 'users',
                            :action => 'show'
  

  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
