# frozen_string_literal: true

namespace :cache do
  desc 'Clear memcache'

  task clear: [:environment] do
    Rails.cache.clear
  end
end
