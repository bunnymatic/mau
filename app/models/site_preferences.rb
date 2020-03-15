# frozen_string_literal: true

require Rails.root.join('app/lib/safe_cache')

class SitePreferences < ApplicationRecord
  self.table_name = :site_preferences

  after_save :write_through_cache

  CACHE_KEY = :site_preferences

  def self.instance(check_cache = false)
    (check_cache && cached) || first || create
  end

  def self.cached
    r = SafeCache.read(CACHE_KEY)
    return nil unless r

    new(JSON.parse(r).with_indifferent_access[:site_preferences])
  end

  def write_through_cache
    SafeCache.write(CACHE_KEY, to_json)
  end
end
