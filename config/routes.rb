# frozen_string_literal: true

Mau::Application.routes.draw do
  resources :media, only: %i[index show]

  resource :user_session, only: %i[new create destroy]
  get '/logout' => 'user_sessions#destroy', as: :logout
  get '/login' => 'user_sessions#new', as: :login
  get '/sign_out' => 'user_sessions#destroy'
  get '/sign_in' => 'user_sessions#new'

  resources :studios, only: %i[index show]

  resource :open_studios, only: [:show] do
    collection do
      get :register
    end
  end

  resource :catalog, only: [:show] do
    member do
      get :social
    end
  end

  resources :art_piece_tags, only: %i[index show] do
    collection do
      post :autosuggest
    end
  end

  resources :feedbacks, only: %i[new create]

  namespace :search do
    match '/', action: 'index', via: %i[get post]
  end

  get '/register' => 'users#create', as: :register
  get '/signup' => 'users#new', as: :signup
  get '/activate/:activation_code' => 'users#activate', as: :activate
  match 'reset/:reset_code' => 'users#reset', as: :reset, via: %i[get post]
  match 'reset' => 'users#reset', as: :submit_reset, via: [:post]

  resources :users do
    resources :favorites, only: %i[index create destroy]
    resources :roles, only: [:destroy]
    collection do
      get :resend_activation
      post :resend_activation
      get :forgot
      post :forgot
      get :deactivate
      get :whoami
    end
    member do
      put :change_password_update
      patch :change_password_update
    end
  end

  get '/mau_fans/:slug', to: redirect('/users/%{slug}'), as: :mau_fan

  resources :art_pieces, only: %i[show edit update destroy]
  resources :artists, except: %i[new create] do
    resources :art_pieces, except: %i[index destroy edit update]
    collection do
      get :roster
      post :destroyart
      get :suggest
      post :setarrangement
      get :my_profile
      get :register_for_current_open_studios
    end
    member do
      resources :favorites, only: [:index]
      get :manage_art
      post :notify_featured
      post :update
      # get :qrcode
    end
  end

  resource :main, controller: :main, only: [] do
    get :notes_mailer
    post :notes_mailer
    post :sampler
  end

  # uptime monitoring (newrelic)
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
      get :map
    end

    get :os_status

    resources :mau_fans, only: [:index]
    resource :palette, only: [:show]
    resource :member_emails, only: [:show]

    namespace :stats do
      get :art_pieces_count_histogram
      get :artists_per_day
      get :art_pieces_per_day
      get :favorites_per_day
      get :user_visits_per_day
      get :os_signups
    end

    match '/discount/markup' => 'discount#markup', as: :discount_processor, via: %i[get post]

    resources :roles
    resources :cms_documents
    resources :blacklist_domains, except: [:show]
    resources :open_studios_events, only: %i[index edit new create update destroy] do
      collection do
        get :clear_cache
      end
    end
    resources :email_lists, only: [:index] do
      resources :emails, only: %i[index create new destroy]
    end
    resources :application_events, only: [:index]
    resources :favorites, only: [:index]
    resources :media, only: %i[index create new edit update destroy]
    resources :artists, only: %i[index edit update] do
      collection do
        post :bulk_update, as: :bulk_update
        get :purge
      end
      member do
        post :suspend
      end
    end
    resources :users, only: [:show]

    resources :art_piece_tags, only: %i[index destroy] do
      collection do
        get :cleanup
      end
    end

    resources :studios, only: %i[index new edit create update destroy] do
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
      resources :artists, only: %i[index show] do
        resources :art_pieces, only: %i[index show], shallow: true
      end
      resources :media, only: %i[index show]
    end
  end

  get '/admin' => 'admin#index', as: :admin

  get '/sitemap.xml' => 'main#sitemap', as: :sitemap

  # legacy urls
  get '/main/openstudios', to: redirect('/open_studios')
  get '/openstudios', to: redirect('/open_studios')

  get '*path' => 'error#index'

  # march 2014 - we should try to get rid of this route
  # match '/:controller(/:action(/:id))'

  root to: 'main#index'
end
