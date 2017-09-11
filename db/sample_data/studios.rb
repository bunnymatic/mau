# frozen_string_literal: true
def ensure_studio(name, *factory_args)
  return if User.find_by(name: name)

  traits, opts = factory_args.partition { |arg| !arg.is_a? Hash }
  options = opts.reduce({}, :merge)
  FactoryGirl.create(*traits, options)
  puts "--> Created studio #{name}"
end

ensure_studio('1890 Bryant', :studio)
ensure_studio('Workspace', :studio)
ensure_studio('Over There', :studio)

Studio.all.each do |studio|
  studio.artists << Artist.active.order('rand()').limit(1)
end
