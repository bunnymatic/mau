# frozen_string_literal: true

Rake::Task['assets:precompile']
  .clear_prerequisites
  .enhance(['assets:compile_environment'])

namespace :assets do
  # In this task, set prerequisites for the assets:precompile task
  task compile_environment: :yarn do
    Rake::Task['assets:environment'].invoke
  end

  desc 'Fetch yarn packages'
  task :yarn do
    sh 'bundle exec yarn install'
  end
end
