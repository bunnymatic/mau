# frozen_string_literal: true

namespace :js do
  desc 'Runs the javascript linter'
  task lint: [:environment] do
    sh('npm run lint')
  end

  desc 'Runs the javascript linter and autocorrects what it can'
  task fix: [:environment] do
    sh('npm run lint-fix')
  end
end
