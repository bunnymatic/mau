namespace :js do
  desc 'run Javascript tests'
  task test: [:environment] do
    success = system('yarn test-ci')
    exit(1) unless success
  end
end
