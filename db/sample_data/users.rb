def ensure_user(login, *factory_args)

  unless User.find_by(login: login)
    traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
    options = opts.reduce Hash.new, :merge
    FactoryGirl.create(*traits, options)
    puts "--> Created account for #{login}"
  end
end

ensure_user("artist", :artist, :active, :with_art)
ensure_user("pending", :artist, :pending)
ensure_user("suspended", :artist, state: :suspended)
ensure_user("admin", :artist, :admin, :with_art)
ensure_user("artfan", :fan)
