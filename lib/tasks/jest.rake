# frozen_string_literal: true

namespace :jest do
  desc 'run Jest tests'
  task test: [:environment] do
    success = system('yarn test -w 1')
    exit(1) unless success
  end
end
