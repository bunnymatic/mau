# frozen_string_literal: true

def ensure_user(login, *factory_args)
  user = User.find_by(login: login)
  return user if User.find_by(login: login)

  traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
  options = opts.reduce({}, :merge).merge(login: login, email: "#{login}@example.com")
  user = FactoryBot.create(*traits, options)
  puts "--> Created account for #{user.login} <#{user.email}>"
  user
end

artist = ensure_user('artist', :artist, :active, :with_art)
addressless = ensure_user('no_address', :artist, :active, :without_address)
ensure_user('pending', :artist, :pending)
ensure_user('suspended', :artist, state: :suspended)
admin = ensure_user('administrator', :artist, :admin, :with_art)
fan = ensure_user('artfan', :fan)

puts '--> Adding favorites'
FavoritesService.add(fan, artist.art_pieces.first)
FavoritesService.add(fan, artist)
FavoritesService.add(addressless, artist)
FavoritesService.add(artist, admin)

puts '--> Adding lots of artists with last names that start with A'
30.times do |_idx|
  username = 'A' + Faker::Internet.username(6..10)
  ensure_user(username, :artist, :active, :with_art, lastname: 'A' + username)
end
