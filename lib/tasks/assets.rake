namespace :assets do
  # task precompile: ['webpacker:compile', :environment]
  # task clobber: ['webpacker:clobber', :environment]
  # # for Capistrano local precompile gem
  desc 'No-op task to please Capistrano deploy:assets:prepare task'
  task clean: [:environment]
end
