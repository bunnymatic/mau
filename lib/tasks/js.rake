# frozen_string_literal: true

namespace :js do
  desc 'Runs the javascript linter'
  task :lint do
    sh('npm run lint')
  end

  desc 'Runs the javascript linter and autocorrects what it can'
  task :fix do
    sh('npm run lint-fix')
  end
end
