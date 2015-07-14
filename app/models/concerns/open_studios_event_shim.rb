# shim to handle migration between oskey/oslive from conf and OpenStudiosEvent.current
module OpenStudiosEventShim
  extend ActiveSupport::Concern

  def current_open_studios_key
    @coskey ||= self.class.current_open_studios_key
  end

  def available_open_studios_keys
    @aoskey ||= self.class.available_open_studios_keys
  end

  module ClassMethods

    def available_open_studios_keys
      ((Conf.open_studios_event_keys + OpenStudiosEvent.pluck(:key)).compact.map(&:to_s).uniq.sort).select{|k| k.present?}
    end

    def current_open_studios_key
      _open_studios_shim_delegate(:key, Conf.oslive)
    end

    private
    def _open_studios_shim_event
      @_open_studios_shim_event ||= OpenStudiosEventService.current
    end

    # delegate to OpenStudiosEvent.current if there is one
    def _open_studios_shim_delegate(method, fallback)
      v = _open_studios_shim_event.send(method) if _open_studios_shim_from_db?
      v.present? ? v : fallback
    end

    def _open_studios_shim_from_db?
      _open_studios_shim_event
    end

  end

end
