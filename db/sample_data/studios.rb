def ensure_studio(name, *factory_args)
  return if Studio.find_by(name:)

  traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
  options = opts.reduce({}, :merge)
  FactoryBot.create(*traits, options)
  puts "--> Created studio #{name}"
end

ensure_studio('1890 Bryant', :studio)
ensure_studio('Workspace', :studio)
ensure_studio('Over There', :studio)

Studio.find_each do |studio|
  studio.artists << Artist.active.order('rand()').limit(1)
end
