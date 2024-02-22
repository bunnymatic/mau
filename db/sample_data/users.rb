class HipsterIpsum
  HOST = 'http://hipsum.co'.freeze
  API_PATH = '/api'.freeze
  DEFAULT_PARAMS = { type: 'hipster-centric' }.freeze

  def self.get(paragraphs: 3)
    params = DEFAULT_PARAMS.merge(paragraphs:)
    conn = Faraday.new(HOST) do |f|
      f.use FaradayMiddleware::FollowRedirects
    end
    JSON.parse(conn.get([API_PATH, params.to_query].join('?')).body).join("\n\n")
  rescue StandardError => e
    <<~EOIPSUM
      Failed to get ipsum #{e.message}.  So here's *some* **markdown**.

      Lorem markdownum movere. Sit novus saturae nusquam, [nec clipeum
      corde](http://cum.org/inimica.aspx). Sanguinis secabatur et iubar canitie
      aeternamque vis vulnera partus spem ducitur? Timidum videre: prius in oscula;
      **cum** animum, et ut lustra harundine velante. Phrygiis latices, conclamat
      versus.

      1. Sonitu reddunt quicquam sonitusque et illum
      2. Sit carcere fiuntque possum
      3. Terras tela satis aethera
      4. Ulterius viri hanc agat tauros visus facit
      5. Est illius inrita

    EOIPSUM
  end
end

def lorem_ipsum_bio
  HipsterIpsum.get(paragraphs: rand(2..4))
end

def ensure_user(login, *factory_args)
  user = User.find_by(login:)
  return user if User.find_by(login:)

  traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
  options = opts.reduce({}, :merge).merge(login:, email: "#{login}@example.com")

  user = FactoryBot.create(*traits, options)
  puts "--> Created account for #{user.login} <#{user.email}>"
  user.artist_info&.update!(bio: lorem_ipsum_bio)
  user
end

artist = ensure_user('artist', :artist, :active, :with_art)
addressless = ensure_user('no_address', :artist, :active, :without_address)
ensure_user('pending', :artist, :pending)
ensure_user('suspended', :artist, state: :suspended)
admin = ensure_user('administrator', :artist, :admin, :with_art)

puts '--> Adding favorites'
begin
  FavoritesService.add(addressless, artist)
  FavoritesService.add(artist, admin)
rescue StandardError
  puts 'Failed to add some favorites - moving on'
end

# s1890 = Studio.friendly.find('1890-bryant-street-studios')

# puts '--> Adding 1890 artists'
# 2.times do |_idx|
#  username = Faker::Internet.username
#  ensure_user(username, :artist, :active, :with_art, number_of_art_pieces: rand(1..4), studio: s1890, lastname: username.capitalize)
# end
