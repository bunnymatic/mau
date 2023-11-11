def ensure_user(login, *factory_args)
  user = User.find_by(login:)
  return user if User.find_by(login:)

  traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
  options = opts.reduce({}, :merge).merge(login:, email: "#{login}@example.com")
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
begin
  FavoritesService.add(fan, artist.art_pieces.first)
  FavoritesService.add(fan, artist)
  FavoritesService.add(addressless, artist)
  FavoritesService.add(artist, admin)
rescue StandardError
  puts 'Failed to add some favorites - moving on'
end

# s1890 = Studio.friendly.find!('1890-bryant-street-studios')

# puts '--> Adding 1890 artists'
# 2.times do |_idx|
#  username = Faker::Internet.username
#  ensure_user(username, :artist, :active, :with_art, number_of_art_pieces: rand(1..4), studio: s1890, lastname: username.capitalize)
# end
