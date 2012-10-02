ActionController::Routing::Routes.draw do |map|
  map.resources :roles
  map.resources :cms_documents
  map.resources :media
  map.resources :artist_feeds
  map.resources :art_pieces
  map.resource  :session
  map.resources :studios, :member => { :addprofile => :get, :upload_profile => :post, :unaffiliate_artist => :post }
  map.resources :application_events, :only => [:index]
  map.resources :catalog, :only => [:index]
  map.resources :email_lists, :only => [:index]
  map.resources :art_piece_tags, :collection => {:cleanup => :get}

  map.resources :events, :member => { :publish => :get, :unpublish => :get }
  map.calendar '/calendar/:year/:month', :controller => 'calendar', :action => 'index', 
	:requirements => {:year => /\d{4}/, :month => /\d{1,2}/}, :year => nil, :month => nil

  map.feedback 'feedbacks', :controller => 'feedbacks', :action => 'create'
  map.new_feedback 'feedbacks/new', :controller => 'feedbacks', :action => 'new'

  map.resources :search, :only => [:index], :collection => {:fetch => :post}

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

  map.resources :artists, 
  :member => {
    :update => :post,
    :bio => :get,
    :qrcode => :get
#    :badge => :get

  }, 
  :collection => { 
    :destroyart => :post, 
    :arrangeart => :get, 
    :setarrangement => :post, 
    :deleteart => :get, 
    :edit => :get,
    :map => :get,
    :thumbs => :get,
    :suggest => :get
  }
  # for mobile
  map.by_lastname '/artists_by_lastname', :controller => 'artists', :action => 'by_lastname'
  map.by_lastname '/artists_by_firstname', :controller => 'artists', :action => 'by_firstname'

  map.resources :users, 
  :member => { :favorites => :get, :suspend => :put, :unsuspend => :put, :purge => :delete, :notify => :put, :noteform => :get }, 
  :collection => { :addprofile => :get, :upload_profile => :post, :deactivate => :get, :add_favorite => :post, :remove_favorite => :post, :resend_activation => [:get, :post], :forgot => :get, :edit => :get } do |users|
    users.resources :roles, :only => [:destroy]
  end


  #map.analytics '/ganalytics', :controller => 'main', :action => 'ganalytics'
  [:faq, :openstudios, :venues, :privacy, :about, :history, :contact, :version].each do |endpoint|
    map.send(endpoint, "/" + endpoint.to_s, :controller => :main, :action => endpoint)
  end

  map.getinvolved '/getinvolved/:p', :controller => 'main', :action => 'getinvolved', :p => nil
  map.artist_resources '/resources', :controller => 'main', :action => 'resources'
  map.news_alt '/news', :controller => 'main', :action => 'resources'
  map.error '/error', :controller => 'error'

  map.admin_update_artists '/admin/artists/update', :controller => 'artists', :action=> 'admin_update'

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

  map.discount_processor '/discount/markup', :controller => 'discount', :action => 'markup'

  # clear this shit out
  #map.flaxartshow '/flaxart', :controller => 'wizards', :action => 'flaxart'
  #map.flaxarteventthingy '/flaxart/eventthingy', :controller => 'wizards', :action => 'flax_eventthingy'
  #map.flaxartchooser '/flaxart/chooser', :controller => 'wizards', :action => 'flax_chooser'
  #map.flaxartsubmitcheck '/flaxart/submit_check', :controller => 'wizards', :action => 'flax_submit_check', :method => :post
  #map.flaxartsubmit '/flaxart/submit', :controller => 'wizards', :action => 'flax_submit', :method => :post
  #map.flaxartpayment '/flaxart/payment', :controller => 'wizards', :action => 'flax_payment'
  #map.flaxartpaymentsuccess '/flaxart/payment_success', :controller => 'wizards', :action => 'flax_success'
  #map.flaxartpaymentcancel '/flaxart/payment_cancel', :controller => 'wizards', :action => 'flax_payment_cancel'
  #map.mau_submissions '/flaxart/:action', :controller => 'wizards'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.mobile_root '/mobile/main', :controller => "mobile/main", :action => 'welcome'
  map.root :controller => "main"
  map.sitemap '/sitemap.xml', :controller => 'main', :action => 'sitemap'
  # See how all your routes lay out with "rake routes"

  # external access - json only
  map.connect '/api/*path', :controller => :api

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '*path', :controller => 'error'

end
