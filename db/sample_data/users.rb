# frozen_string_literal: true
def ensure_user(login, *factory_args)
  return if User.find_by(login: login)

  traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
  options = opts.reduce({}, :merge).merge(login: login, email: "#{login}@example.com")
  user = FactoryGirl.create(*traits, options)
  puts "--> Created account for #{user.login} <#{user.email}>"
end

ensure_user('artist', :artist, :active, :with_art)
ensure_user('pending', :artist, :pending)
ensure_user('suspended', :artist, state: :suspended)
ensure_user('administrator', :artist, :admin, :with_art)
ensure_user('artfan', :fan)
