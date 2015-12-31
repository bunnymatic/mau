Mau::Application.routes.draw do

  resources :media, only: [:index, :show]

  resource :user_session, only: [:new, :create, :destroy]
  get '/logout' => 'user_sessions#destroy', as: :logout
  get '/login' => 'user_sessions#new', as: :login


  resources :studios, only: [:index, :show]

  resource :feeds, only: [] do
    get :feed
    get :clear_cache
  end
  resource :open_studios, only: [:show]
  resource :catalog, only: [:show] do
    member do
      get :social
    end
  end

  resources :art_piece_tags, only: [:index, :show] do
    collection do
      post :autosuggest
    end
  end

  resources :feedbacks, only: [:new, :create]

  namespace :search do
    match '/', action: 'index', via: [:get,:post]
  end

  get '/register' => 'users#create', as: :register
  get '/signup' => 'users#new', as: :signup
  get '/activate/:activation_code' => 'users#activate', as: :activate
  match 'reset/:reset_code' => 'users#reset', as: :reset, via: [:get, :post]
  match 'reset' => 'users#reset', as: :submit_reset, via: [:post]


  resources :users do
    collection do
      get :resend_activation
      post :resend_activation
      get :forgot
      post :forgot
      get :deactivate
      post :remove_favorite
      post :add_favorite
    end
    member do
      resources :favorites, only: [:index]
      put :suspend
      put :change_password_update
      patch :change_password_update
    end
    resources :roles, only: [:destroy]
  end


  resources :art_pieces, only: [:show, :edit, :update, :destroy]
  resources :artists, except: [:new, :create] do
    resources :art_pieces, except: [:new, :destroy, :edit, :update]
    collection do
      get :roster
      post :destroyart
      get :suggest
      post :setarrangement
      # get :map_page, as: :map
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
    post :sampler
  end

  get '/status' => 'main#status_page', as: :status
  get '/faq' => 'main#faq', as: :faq
  get '/venues' => 'main#venues', as: :venues
  get '/privacy' => 'main#privacy', as: :privacy
  get '/about' => 'main#about', as: :about
  get '/contact' => 'main#contact', as: :contact
  get '/version' => 'main#version', as: :version
  get '/resources' => 'main#resources', as: :artist_resources
  get '/error' => 'error#index', as: :error

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
    get :db_backups
    get :fetch_backup
    get :palette
    get :featured_artist
    get :emaillist
    post :emaillist

    namespace :stats do
      get :art_pieces_count_histogram
      get :artists_per_day
      get :art_pieces_per_day
      get :favorites_per_day
      get :user_visits_per_day
      get :os_signups
    end

    get '/discount/markup' => 'discount#markup', as: :discount_processor, via: [:get, :post]

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
        post :suspend
        get :notify_featured
      end
    end
    resources :art_piece_tags, only: [:index, :destroy] do
      collection do
        get :cleanup
      end
    end

    resources :studios, only: [:index, :new, :edit, :create, :update, :destroy] do
      collection do
        post :reorder
      end
      member do
        post :unaffiliate_artist
      end
    end

  end

  namespace :api do
    namespace :v2 do
      resources :studios, only: [:show]
      resources :artists, only: [:index, :show] do
        resources :art_pieces, only: [:index, :show], shallow: true
      end
      resources :media, only: [:index, :show]
    end
  end

  get '/admin' => 'admin#index', as: :admin

  get '/sitemap.xml' => 'main#sitemap', as: :sitemap
  get '/api/*path' => 'api#index'


  # legacy urls
  get '/main/openstudios', to: redirect('/open_studios')
  get '/openstudios', to: redirect("/open_studios")

  get '*path' => 'error#index'

  # march 2014 - we should try to get rid of this route
  #match '/:controller(/:action(/:id))'

  root to: "main#index"

end
