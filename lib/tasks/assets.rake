require 'rake'
namespace :assets do
  # task precompile: ['webpacker:compile', :environment]
  # task clobber: ['webpacker:clobber', :environment]
  # # for Capistrano local precompile gem
  # task clean: ['webpacker:clobber', :environment]

  task before: :environment do
    puts 'Before assets'
  end

  task after: :environment do
    puts 'after assets'
  end
end

begin
  Rake::Task['deploy:assets:rsync'].enhance(['assets:before']) do
    Rake::Task['assets:after'].execute
  end
rescue StandardError => e
  puts e
  puts 'whatever'
end
