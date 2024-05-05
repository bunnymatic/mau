# manage caching the list of open studios events
class OpenStudiosEventService
  CURRENT_CACHE_KEY = :current_os_event
  FUTURE_CACHE_KEY = :future_os_events
  PAST_CACHE_KEY = :past_os_events

  def self.for_display(os_key, month_first: false)
    os = find_by_key(os_key)
    os ? os.for_display(month_first:) : 'n/a'
  end

  def self.all
    OpenStudiosEvent.order(start_date: :desc)
  end

  def self.update(open_studios_event, attributes)
    clear_cache(open_studios_event)
    open_studios_event.update(attributes)
  end

  def self.save(open_studios_event)
    clear_cache(open_studios_event)
    open_studios_event.save
  end

  def self.current
    return nil unless SitePreferences.instance(check_cache: true).open_studios_active?

    cache = SafeCache.read(CURRENT_CACHE_KEY)
    unless cache
      cache = OpenStudiosEvent.current
      SafeCache.write(CURRENT_CACHE_KEY, cache)
    end
    cache
  end

  def self.future
    cache = SafeCache.read(FUTURE_CACHE_KEY)
    unless cache
      cache = OpenStudiosEvent.future
      SafeCache.write(FUTURE_CACHE_KEY, cache)
    end
    cache
  end

  def self.past
    cache = SafeCache.read(PAST_CACHE_KEY)
    unless cache
      cache = OpenStudiosEvent.past
      SafeCache.write(PAST_CACHE_KEY, cache)
    end
    cache
  end

  def self.where(*args)
    OpenStudiosEvent.where(*args)
  end

  def self.find_by_key(key, cached: true)
    if cached
      event = SafeCache.read(event_cache_key(key))
      unless event
        event = OpenStudiosEvent.find_by(key:)
        SafeCache.write(event_cache_key(key), event)
      end
    else
      event = OpenStudiosEvent.find_by(key:)
    end
    event
  end

  def self.destroy(os_event)
    clear_cache(os_event)
    os_event.destroy
  end

  def self.clear_cache(event = nil)
    SafeCache.delete(FUTURE_CACHE_KEY)
    SafeCache.delete(PAST_CACHE_KEY)
    SafeCache.delete(CURRENT_CACHE_KEY)
    return unless event

    SafeCache.delete(event_cache_key(event.id))
    SafeCache.delete(event_cache_key(event.key))
  end

  # tally up today's open studios count
  def self.tally_os
    return unless current

    today = Time.zone.now.to_date
    count = current.try(:artists).count

    o = OpenStudiosTally.find_by(recorded_on: today)
    if o
      o.update(oskey: current.key, count:)
    else
      OpenStudiosTally.create!(oskey: current.key, count:, recorded_on: today)
    end
  end

  def self.event_cache_key(id)
    "os_event_#{id}"
  end
end
