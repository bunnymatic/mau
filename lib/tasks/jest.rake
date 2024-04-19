namespace :js do
  desc 'run Javascript tests'
  task test: [:environment] do
    success = system('yarn test -w 1')
    exit(1) unless success
  end
end
