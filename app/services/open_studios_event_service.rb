# frozen_string_literal: true

# manage caching the list of open studios events
class OpenStudiosEventService
  CURRENT_CACHE_KEY = :current_os_event
  FUTURE_CACHE_KEY = :future_os_events
  PAST_CACHE_KEY = :past_os_events

  def self.for_display(os_key, reverse = false)
    os = OpenStudiosEvent.find_by(key: os_key)
    return os.for_display(reverse) if os

    parse_key(os_key, reverse) || 'n/a'
  end

  def self.date(os_key)
    os = OpenStudiosEvent.find_by(key: os_key)
    return os.start_date if os

    parsed = parse_key(os_key, true)
    return Time.zone.parse(parsed) if parsed

    # fallback
    Time.zone.now - 10.years
  end

  def self.parse_key(os_key, reverse = false)
    return nil if os_key.blank?

    os_key = os_key.to_s
    yr = os_key[0..3]
    mo = os_key[4..-1]
    seas = mo == '10' ? 'Oct' : 'Apr'
    (reverse ? [seas, yr] : [yr, seas]).join(' ')
  end

  def self.all
    OpenStudiosEvent.order(start_date: :desc)
  end

  def self.update(open_studios_event, attributes)
    clear_cache(open_studios_event.id)
    open_studios_event.update(attributes)
  end

  def self.save(open_studios_event)
    clear_cache(open_studios_event.id)
    open_studios_event.save
  end

  def self.current
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

  def self.find_by(*args)
    OpenStudiosEvent.find_by(*args).tap do |event|
      SafeCache.write(event_cache_key(event.id), event) if event
    end
  end

  def self.find(id, use_cache = true)
    if use_cache
      cache = SafeCache.read(event_cache_key(id))
      unless cache
        cache = OpenStudiosEvent.find(id)
        SafeCache.write(event_cache_key(id), cache)
      end
    else
      cache = OpenStudiosEvent.find(id)
    end
    cache
  end

  def self.destroy(os_event)
    clear_cache(os_event.id)
    os_event.destroy
  end

  def self.clear_cache(id = nil)
    SafeCache.delete(event_cache_key(id)) if id
    SafeCache.delete(FUTURE_CACHE_KEY)
    SafeCache.delete(PAST_CACHE_KEY)
    SafeCache.delete(CURRENT_CACHE_KEY)
  end

  def self.event_cache_key(id)
    "os_event_#{id}"
  end
end
