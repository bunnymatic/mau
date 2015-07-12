# manage caching the list of open studios events
class OpenStudiosEventService

  CURRENT_CACHE_KEY = :current_os_event
  FUTURE_CACHE_KEY = :future_os_events
  PAST_CACHE_KEY = :past_os_events
  
  def self.for_display(os_key = nil, reverse = false )
    if !os_key
      OpenStudiosEvent.current.try(:for_display,reverse)
    else
      #puts "*************************** OSKEY IS NOT NIL ************************"
      if os = OpenStudiosEvent.find_by_key(os_key)
        os.for_display(reverse)
      elsif os_key
        os_key = os_key.to_s
        yr = os_key[0..3]
        mo = os_key[4..-1]
        seas = (mo == '10') ? 'Oct':'Apr'
        "%s %s" % (reverse ? [seas,yr] : [ yr, seas ])
      else
        'n/a'
      end
    end
  end

  def self.all
    OpenStudiosEvent.all
  end
  
  def self.update(open_studios_event, attributes)
    clear_cache(open_studios_event.id)
    open_studios_event.update_attributes(attributes)
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
    cache = SafeCache.read(PAST_CACHE_KEY)
    unless cache
      cache = OpenStudiosEvent.past
      SafeCache.write(PAST_CACHE_KEY, cache)
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
    if id
      SafeCache.delete(event_cache_key(id))
    end
    SafeCache.delete(FUTURE_CACHE_KEY)
    SafeCache.delete(PAST_CACHE_KEY)
    SafeCache.delete(CURRENT_CACHE_KEY)
  end

  def self.event_cache_key(id)
    "os_event_#{id}"
  end
end
