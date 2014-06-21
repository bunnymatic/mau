Mau::Application.routes.draw do

  resources :blacklist_domains, :except => [:show]
  resources :roles
  resources :cms_documents, :except => [:destroy]
  resources :media, :only => [:index, :show]

  resource :user_session
  match '/logout' => 'user_sessions#destroy', :as => :logout
  match '/login' => 'user_sessions#new', :as => :login


  resources :studios, :only => [:index, :show]

  resources :artist_feeds, :except => [:show]
  resource :feeds, :only => [] do
    get :feed
    get :clear_cache
  end
  resources :catalog, :only => [:index] do
    collection do
      get :social
    end
  end

  resources :art_piece_tags, :only => [:index, :show] do
    collection do
      post :autosuggest # autocomplete for prototype doesn't easily do ajax with authenticity token :(
    end
  end

  resources :events

  match '/calendar/:year/:month' => 'calendar#index', :as => :calendar, :constraints => { :month => /\d{1,2}/, :year => /\d{4}/ }
  match '/calendar' => 'calendar#index', :as => :calendar

  resources :feedbacks, :only => [:new, :create]

  namespace :search do
    match '/', :action => 'index', :via => [:get,:post]
    match '/fetch', :action => 'fetch', :via => [:get, :post]
  end

  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  match '/change_password' => 'users#change_password', :as => :change_password
  match '/change_password_update' => 'users#change_password_update', :as => :change_password_update
  match '/activate/:activation_code' => 'users#activate', :as => :activate
  match 'reset/:reset_code' => 'users#reset', :as => :reset, :via => [:get, :post]
  match 'reset' => 'users#reset', :as => :submit_reset, :method => :post


  resources :art_pieces, :only => [:show, :edit, :update, :destroy]
  resources :artists, :except => [:new, :create] do
    resources :art_pieces, :except => [:index, :destroy, :edit, :update]
    collection do
      get :by_lastname
      get :by_firstname
      get :roster
      get :thumbs
      get :osthumbs
      post :destroyart
      get :suggest
      get :arrange_art
      get :delete_art
      post :setarrangement
      get :map_page, :as => :map
      get :edit
    end
    member do
      post :notify_featured
      post :update
      get :bio
      get :qrcode
    end
  end

  resources :users do
    collection do
      post :remove_favorite
      post :upload_profile
      get :resend_activation
      post :resend_activation
      get :forgot
      post :forgot
      get :deactivate
      get :edit
      post :add_favorite
      get :add_profile
    end
    member do
      put :suspend
      get :noteform
      put :notify
      get :favorites
    end
    resources :roles, :only => [:destroy]
  end

  resource :main, :controller => :main do
    get :notes_mailer
    post :notes_mailer
    get :letter_from_howard_flax
    get :sampler
  end

  resource :tests, :only => [:show] do
    get :custom_map
    get :flash_test
    get :qr
    get :markdown
  end


  match '/status' => 'main#status_page', :as => :status
  match '/faq' => 'main#faq', :as => :faq
  match '/open_studios' => 'main#open_studios', :as => :open_studios
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

  namespace :admin do
    resources :open_studios_events
    resources :email_lists, :only => [:index, :new, :destroy] do
      collection do
        post :add
      end
    end

    resources :application_events, :only => [:index]
    resources :favorites, :only => [:index]
    resources :media, :only => [:index, :create, :new, :edit, :update, :destroy]
    resources :artists, :only => [:index] do
      collection do
        post :update, :as => :update
        get :purge
      end
      member do
        get :notify_featured
      end
    end
    resources :art_piece_tags, :only => [:index, :destroy] do
      collection do
        get :cleanup
      end
    end

    resources :studios, :only => [:index, :new, :edit, :create, :update, :destroy] do
      member do
        post :upload_profile
        post :unaffiliate_artist
        get :add_profile
      end
    end

    resources :events, :only => [:index] do
      member do
        get :unpublish
        post :unpublish
        get :publish
        post :publish
      end
    end
  end

  match '/admin/featured_artist' => 'admin#featured_artist', :as => :get_next_featured, :method => 'post'
  match '/admin/:action' => 'admin#index', :as => :admin
  match '/maufans/:id' => 'users#show', :as => :mau_fans
  match '/discount/markup' => 'discount#markup', :as => :discount_processor
  match '/mobile/main' => 'mobile/main#welcome', :as => :mobile_root
  match '/sitemap.xml' => 'main#sitemap', :as => :sitemap
  match '/api/*path' => 'api#index'

  # legacy urls
  get '/main/openstudios', to: redirect('/open_studios')
  get '/openstudios', to: redirect("/open_studios")

  match '*path' => 'error#index'

  # march 2014 - we should try to get rid of this route
  #match '/:controller(/:action(/:id))'

  root :to => "main#index"

end
