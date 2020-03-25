# frozen_string_literal: true

namespace :assets do
  task precompile: ['webpacker:compile', :environment]
  task clobber: ['webpacker:clobber', :environment]
end
