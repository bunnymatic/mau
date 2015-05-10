Mau::Application.routes.draw do

  resources :media, only: [:index, :show]

  resource :user_session, only: [:new, :create, :destroy]
  match '/logout' => 'user_sessions#destroy', as: :logout
  match '/login' => 'user_sessions#new', as: :login


  resources :studios, only: [:index, :show]

  resource :feeds, only: [] do
    get :feed
    get :clear_cache
  end
  resources :catalog, only: [:index] do
    collection do
      get :social
    end
  end

  resources :art_piece_tags, only: [:index, :show] do
    collection do
      post :autosuggest
    end
  end

  resources :events

  match '/calendar/:year/:month' => 'calendar#index',
    as: :calendar,
    constraints: { month: /\d{1,2}/, year: /\d{4}/ }
  match '/calendar' => 'calendar#index', as: :calendar

  resources :feedbacks, only: [:new, :create]

  namespace :search do
    match '/', action: 'index', via: [:get,:post]
    match '/fetch', action: 'fetch', via: [:get, :post]
  end

  match '/register' => 'users#create', as: :register
  match '/signup' => 'users#new', as: :signup
  match '/activate/:activation_code' => 'users#activate', as: :activate
  match 'reset/:reset_code' => 'users#reset', as: :reset, via: [:get, :post]
  match 'reset' => 'users#reset', as: :submit_reset, method: :post


  resources :users do
    collection do
      get :resend_activation
      post :resend_activation
      get :forgot
      post :forgot
      get :deactivate
      get :edit
      post :remove_favorite
      post :add_favorite
    end
    member do
      resources :favorites, only: [:index]
      put :suspend
      put :change_password_update
    end
    resources :roles, only: [:destroy], controller: 'Admin::Roles'
  end


  resources :art_pieces, only: [:show, :edit, :update, :destroy]
  resources :artists, except: [:new, :create] do
    resources :art_pieces, except: [:new, :destroy, :edit, :update]
    collection do
      get :roster
      post :destroyart
      get :suggest
      get :arrange_art
      get :delete_art
      post :setarrangement
      get :map_page, as: :map
      get :edit
    end
    member do
      resources :favorites, only: [:index]
      get :manage_art
      post :notify_featured
      post :update
      get :qrcode
    end
  end

  resource :main, controller: :main, only: [] do
    get :notes_mailer
    post :notes_mailer
    get :sampler
  end

  match '/status' => 'main#status_page', as: :status
  match '/faq' => 'main#faq', as: :faq
  match '/open_studios' => 'main#open_studios', as: :open_studios
  match '/venues' => 'main#venues', as: :venues
  match '/privacy' => 'main#privacy', as: :privacy
  match '/about' => 'main#about', as: :about
  match '/history' => 'main#history', as: :history
  match '/contact' => 'main#contact', as: :contact
  match '/version' => 'main#version', as: :version
  match '/non_mobile' => 'main#non_mobile', as: :non_mobile
  match '/mobile' => 'main#mobile', as: :mobile
  match '/getinvolved/:p' => 'main#getinvolved', as: :getinvolved
  match '/getinvolved' => 'main#getinvolved', as: :getinvolved
  match '/resources' => 'main#resources', as: :artist_resources
  match '/news' => 'main#resources', as: :news_alt
  match '/error' => 'error#index', as: :error

  namespace :admin do
    resource :tests, only: [:show] do
      get :custom_map
      get :flash_test
      get :qr
      post :qr
      get :markdown
      get :social_icons
    end
    get :fans
    get :os_status
    get :os_signups
    get :db_backups
    get :fetch_backup
    get :palette
    get :featured_artist
    get :artists_per_day
    get :art_pieces_per_day
    get :favorites_per_day
    get :emaillist
    post :emaillist

    match '/discount/markup' => 'discount#markup', as: :discount_processor

    post :featured_artist, as: :get_next_featured

    resources :roles
    resources :cms_documents
    resources :blacklist_domains, except: [:show]
    resources :artist_feeds, except: [:show]
    resources :open_studios_events, only: [:index, :edit, :new, :create, :update, :destroy]
    resources :email_lists, only: [:index] do
      resources :emails, only: [:index, :create, :new, :destroy]
    end
    resources :application_events, only: [:index]
    resources :favorites, only: [:index]
    resources :media, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :artists, only: [:index] do
      collection do
        post :update, as: :update
        get :purge
      end
      member do
        get :notify_featured
      end
    end
    resources :art_piece_tags, only: [:index, :destroy] do
      collection do
        get :cleanup
      end
    end

    resources :studios, only: [:index, :new, :edit, :create, :update, :destroy] do
      member do
        post :upload_profile
        post :unaffiliate_artist
        get :add_profile
      end
    end

    resources :events, only: [:index] do
      member do
        get :unpublish
        post :unpublish
        get :publish
        post :publish
      end
    end
  end

  match '/admin' => 'admin#index', as: :admin

  match '/mobile/main' => 'mobile/main#welcome', as: :mobile_root
  match '/sitemap.xml' => 'main#sitemap', as: :sitemap
  match '/api/*path' => 'api#index'

  # legacy urls
  get '/main/openstudios', to: redirect('/open_studios')
  get '/openstudios', to: redirect("/open_studios")

  match '*path' => 'error#index'

  # march 2014 - we should try to get rid of this route
  #match '/:controller(/:action(/:id))'

  root to: "main#index"

end
