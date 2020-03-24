# frozen_string_literal: true

namespace :assets do
  task precompile: ['webpacker:compile', :npm, :environment]

  desc 'Fetch npm packages'
  task npm: [:environment] do
    sh 'bundle exec yarn install'
  end
end
