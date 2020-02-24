# frozen_string_literal: true

require 'fileutils'

if Rails.env.development?
  cache_path = Rails.root.join('tmp/cache/assets/sprockets')
  FileUtils.rm_rf(cache_path)

  listener = Listen.to(Rails.root.join('app/assets/components')) do |_modified, _added, _removed|
    # clearing cache
    FileUtils.rm_rf(cache_path)
  end
  listener.start
end
