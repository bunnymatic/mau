Mau::Application.routes.draw do

  resources :blacklist_domains, :except => [:show]
  resources :roles
  resources :cms_documents, :except => [:destroy]
  resources :media
  resources :artist_feeds, :except => [:show]
  resources :art_pieces, :except => ['index']
  resource :session, :only => [:new, :create, :destroy]
  resources :studios do
    member do
      post :upload_profile
      post :unaffiliate_artist
      get :addprofile
    end
  end

  resources :application_events, :only => [:index]
  resources :catalog, :only => [:index] do
    collection do
      get :social
    end
  end

  resources :email_lists, :only => [:index]
  resources :art_piece_tags do
    collection do
      get :cleanup
    end
  end

  resources :events do
    member do
      get :unpublish
      get :publish
    end
  end

  match '/calendar/:year/:month' => 'calendar#index', :as => :calendar, :constraints => { :month => /\d{1,2}/, :year => /\d{4}/ }
  match '/calendar' => 'calendar#index', :as => :calendar

  match 'feedbacks' => 'feedbacks#create', :as => :feedback
  match 'feedbacks/new' => 'feedbacks#new', :as => :new_feedback
  resources :search, :only => [:index] do
    collection do
      post :fetch
    end
  end

  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  match '/change_password' => 'users#change_password', :as => :change_password
  match '/change_password_update' => 'users#change_password_update', :as => :change_password_update
  match '/activate/:activation_code' => 'users#activate', :as => :activate
  match 'reset/:reset_code' => 'users#reset', :as => :reset, :method => :get
  match 'reset' => 'users#reset', :as => :submit_reset, :method => :post
  resources :artists, :except => [:new, :create] do
    collection do
      get :roster
      get :thumbs
      get :osthumbs
      post :destroyart
      get :suggest
      get :arrangeart
      post :setarrangement
      get :map_page, :as => :map
      get :edit
      get :deleteart
    end
    member do
      post :notify_featured
      post :update
      get :bio
      get :qrcode
    end
  end

  match '/artists_by_lastname' => 'artists#by_lastname', :as => :by_lastname
  match '/artists_by_firstname' => 'artists#by_firstname', :as => :by_lastname
  resources :users do
    collection do
      post :remove_favorite
      post :upload_profile
      get :resend_activation
      post :resend_activation
      get :forgot
      get :deactivate
      get :edit
      post :add_favorite
      get :addprofile
    end
    member do
      put :suspend
      put :unsuspend
      get :noteform
      put :notify
      delete :purge
      get :favorites
    end
    resources :roles, :only => [:destroy]
  end

  match '/status' => 'main#status_page', :as => :status
  match '/faq' => 'main#faq', :as => :faq
  match '/openstudios' => 'main#openstudios', :as => :openstudios
  match '/venues' => 'main#venues', :as => :venues
  match '/privacy' => 'main#privacy', :as => :privacy
  match '/about' => 'main#about', :as => :about
  match '/history' => 'main#history', :as => :history
  match '/contact' => 'main#contact', :as => :contact
  match '/version' => 'main#version', :as => :version
  match '/non_mobile' => 'main#non_mobile', :as => :non_mobile
  match '/mobile' => 'main#mobile', :as => :mobile
  match '/getinvolved/:p' => 'main#getinvolved', :as => :getinvolved
  match '/getinvolved' => 'main#getinvolved', :as => :getinvolved
  match '/resources' => 'main#resources', :as => :artist_resources
  match '/news' => 'main#resources', :as => :news_alt
  match '/error' => 'error#index', :as => :error
  match '/admin/artists/update' => 'artists#admin_update', :as => :admin_update_artists
  match '/admin/events' => 'events#admin_index', :as => :admin_events
  match '/admin/artists' => 'artists#admin_index', :as => :admin_artists
  match '/admin/studios' => 'studios#admin_index', :as => :admin_studios
  match '/admin/art_piece_tags' => 'art_piece_tags#admin_index', :as => :admin_tags
  match '/admin/media' => 'media#admin_index', :as => :admin_media
  match '/admin/favorites' => 'favorites#index', :as => :admin_favorites
  match '/admin/featured_artist' => 'admin#featured_artist', :as => :get_next_featured, :method => 'post'
  match '/admin/:action' => 'admin#index', :as => :admin
  match '/maufans/:id' => 'users#show', :as => :mau_fans
  match '/discount/markup' => 'discount#markup', :as => :discount_processor
  match '/mobile/main' => 'mobile/main#welcome', :as => :mobile_root
  match '/' => 'main#index'
  match '/sitemap.xml' => 'main#sitemap', :as => :sitemap
  match '/api/*path' => 'api#index'
  match '/:controller(/:action(/:id))'
  match '*path' => 'error#index'

  root :to => "main#index"

end
