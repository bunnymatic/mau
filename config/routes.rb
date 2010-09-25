ActionController::Routing::Routes.draw do |map|

  map.feedback 'feedbacks', :controller => 'feedbacks', :action => 'create'
  map.new_feedback 'feedbacks/new', :controller => 'feedbacks', :action => 'new'

  map.resources :media

#  map.resources :events
#  map.resources :venues

  map.resources :art_pieces

  map.autosuggesttag '/tags/autosuggest', :controller => 'tags', :action => 'autosuggest'
  map.resources :tags

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'artists', :action => 'create'
  map.signup '/signup', :controller => 'artists', :action => 'new'
  map.change_password '/change_password', :controller => 'artists', :action => 'change_password'  
  map.change_password_update '/change_password_update', :controller => 'artists', :action => 'change_password_update'  
  map.activate '/activate/:activation_code', :controller => 'artists', :action => 'activate', :activation_code => nil
  map.forgot '/forgot', :controller => 'artists', :action => 'forgot'
  map.resend_activation '/resend_activation', :controller => 'artists', :action => 'resend_activation'
  map.reset 'reset/:reset_code', :controller => 'artists',     :action => 'reset'

  map.artistsmap '/artists/map', :controller => 'artists', :action => 'map'
  map.artistsHUGEmap '/artists/hugemap', :controller => 'artists', :action => 'hugemap'

  map.faq '/artists/faq', :controller => 'artists', :action => 'faq'
  map.badge '/artists/:id/badge', :controller => 'artists', :action => 'badge'

  map.resources :artists, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete, :notify => :put, :noteform => :get, :arrangeart => :get, :setarrangement => :post, :deleteart => :get, :addprofile => :get }

  map.resource :session

  map.resources :studios

  #map.analytics '/ganalytics', :controller => 'main', :action => 'ganalytics'
  map.venues '/venues', :controller => 'main', :action => 'venues'
  map.getinvolved '/getinvolved/:p', :controller => 'main', :action => 'getinvolved', :p => nil
  map.privacy '/privacy', :controller => 'main', :action => 'privacy'
  map.about '/about/:id', :controller => 'main', :action => 'about'
  map.news '/news', :controller => 'main', :action => 'news'
  map.contact '/contact', :controller => 'main', :action => 'contact'
  map.error '/error', :controller => 'error'
  map.version '/_rev', :controller => 'main', :action => 'version'

  # admin links
  map.admin_artists '/admin/artists', :controller => 'artists', :action=> 'admin_index'
  map.admin_update_artists '/admin/artists/update', :controller => 'artists', :action=> 'admin_update'

  map.admin_studios '/admin/studios', :controller => 'studios', :action=> 'admin_index'
  map.admin_tags '/admin/tags', :controller => 'tags', :action=> 'admin_index'
  map.admin_media '/admin/media', :controller => 'media', :action=> 'admin_index'
  # all other admin links connect to AdminController

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
  
  # Sample resource route with more complex su/deletb-resources
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
  map.root :controller => "main"
  

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '*path', :controller => 'error'

end
