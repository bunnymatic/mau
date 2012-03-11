ActionController::Routing::Routes.draw do |map|
  map.resources :events, :member => { :publish => :get, :unpublish => :get }
  map.resources :cms_documents
  map.resources :media
  map.resources :artist_feeds

  map.feedback 'feedbacks', :controller => 'feedbacks', :action => 'create'
  map.new_feedback 'feedbacks/new', :controller => 'feedbacks', :action => 'new'

  map.resources :art_pieces
  map.resources :art_piece_tags, :collection => {:cleanup => :get}

  map.force_non_mobile '/non_mobile', :controller => 'application', :action => 'non_mobile'

  # user account related remaps
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'  
  map.change_password_update '/change_password_update', :controller => 'users', :action => 'change_password_update'  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.reset 'reset/:reset_code', :controller => 'users', :action => 'reset', :method => :get
  map.submit_reset 'reset', :controller => 'users', :action => 'reset', :method => :post

  # clear this shit out
  map.flaxartshow '/flaxart', :controller => 'wizards', :action => 'flaxart'
  map.flaxarteventthingy '/flaxart/eventthingy', :controller => 'wizards', :action => 'flax_eventthingy'
  map.flaxartchooser '/flaxart/chooser', :controller => 'wizards', :action => 'flax_chooser'
  map.flaxartsubmitcheck '/flaxart/submit_check', :controller => 'wizards', :action => 'flax_submit_check', :method => :post
  map.flaxartsubmit '/flaxart/submit', :controller => 'wizards', :action => 'flax_submit', :method => :post
  map.flaxartpayment '/flaxart/payment', :controller => 'wizards', :action => 'flax_payment'
  map.flaxartpaymentsuccess '/flaxart/payment_success', :controller => 'wizards', :action => 'flax_success'
  map.flaxartpaymentcancel '/flaxart/payment_cancel', :controller => 'wizards', :action => 'flax_payment_cancel'

  map.mau_submissions '/flaxart/:action', :controller => 'wizards'


  map.faq '/faq', :controller => 'main', :action => 'faq'
  map.openstudios '/openstudios', :controller => 'main', :action => 'openstudios'
  map.badge '/artists/:id/badge', :controller => 'artists', :action => 'badge'


  map.resources :artists, 
  :member => {
    :update => :post,
    :bio => :get
  }, 
  :collection => { 
    :destroyart => :post, 
    :arrangeart => :get, 
    :setarrangement => :post, 
    :deleteart => :get, 
    :edit => :get,
    :map => :get,
    :thumbs => :get
  }
  # for mobile
  map.by_lastname '/artists_by_lastname', :controller => 'artists', :action => 'by_lastname'
  map.by_lastname '/artists_by_firstname', :controller => 'artists', :action => 'by_firstname'

  map.resources :users, :member => { :favorites => :get, :suspend => :put, :unsuspend => :put, :purge => :delete, :notify => :put, :noteform => :get }, :collection => { :addprofile => :get, :upload_profile => :post, :deactivate => :get, :add_favorite => :post, :remove_favorite => :post, :resend_activation => [:get, :post], :forgot => :get, :edit => :get }


  # figure out the right way to route this
  map.mobile_artists '/mobile/artists', :controller => 'mobile/artists', :action => 'index'
  map.mobile_studios '/mobile/studios', :controller => 'mobile/studios', :action => 'index'
  map.mobile_artist '/mobile/artists/:id', :controller => 'mobile/artists', :action => 'show'
  map.mobile_studio '/mobile/studios/:id', :controller => 'mobile/studios', :action => 'show'

  map.resource :session

  map.resources :studios

  #map.analytics '/ganalytics', :controller => 'main', :action => 'ganalytics'
  map.venues '/venues', :controller => 'main', :action => 'venues'
  map.getinvolved '/getinvolved/:p', :controller => 'main', :action => 'getinvolved', :p => nil
  map.privacy '/privacy', :controller => 'main', :action => 'privacy'
  map.about '/about', :controller => 'main', :action => 'about'
  map.history '/history', :controller => 'main', :action => 'history'
  map.artist_resources '/resources', :controller => 'main', :action => 'resources'
  map.news_alt '/news', :controller => 'main', :action => 'resources'
  map.contact '/contact', :controller => 'main', :action => 'contact'
  map.error '/error', :controller => 'error'
  map.version '/_rev', :controller => 'main', :action => 'version'

  map.admin_update_artists '/admin/artists/update', :controller => 'artists', :action=> 'admin_update'

  map.email_list '/email_list/:action', :controller => :email_list

  map.admin_events '/admin/events', :controller => 'events', :action=> 'admin_index'
  map.admin_artists '/admin/artists', :controller => 'artists', :action=> 'admin_index'
  map.admin_studios '/admin/studios', :controller => 'studios', :action=> 'admin_index'
  map.admin_tags '/admin/art_piece_tags', :controller => 'art_piece_tags', :action=> 'admin_index'
  map.admin_media '/admin/media', :controller => 'media', :action=> 'admin_index'
  map.admin_favorites '/admin/favorites', :controller => 'favorites', :action=> 'index'

  # admin links
  map.get_next_featured '/admin/featured_artist', :controller => :admin, :action => 'featured_artist', :method => 'post'
  map.admin '/admin/:action', :controller => :admin

  map.mau_fans '/maufans/:id', :controller => 'users', :action => 'show'
  # all other admin links connect to AdminController

  map.discount_processor '/discount/markup', :controller => 'discount', :action => 'markup'
  
  map.catalog '/catalog/:action', :controller => 'catalog'

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
  map.mobile_root '/mobile/main', :controller => "mobile/main", :action => 'welcome'
  map.root :controller => "main"
  map.sitemap '/sitemap.xml', :controller => 'main', :action => 'sitemap'
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '*path', :controller => 'error'

end
