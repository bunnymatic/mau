namespace :js do
  desc 'Runs the javascript linter'
  task lint: [:environment] do
    sh('npm run lint')
  end

  desc 'Runs the javascript linter and autocorrects what it can'
  task fix: [:environment] do
    sh('npm run lint-fix')
  end

  desc 'Run Javascript tests'
  task test: [:environment] do
    success = system('yarn test-ci')
    exit(1) unless success
  end
end
