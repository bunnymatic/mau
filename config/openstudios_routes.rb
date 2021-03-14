scope module: 'open_studios_subdomain' do
  get '/', to: 'main#index'
  resources :artists, only: [:show], as: :artist_open_studios
end
