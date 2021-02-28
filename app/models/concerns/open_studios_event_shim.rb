# shim to handle migration between oskey/oslive from conf and OpenStudiosEvent.current
module OpenStudiosEventShim
  extend ActiveSupport::Concern

  def current_open_studios_key
    @current_open_studios_key ||= OpenStudiosEventService.current.try(:key)
  end

  module ClassMethods
    def current_open_studios_key
      _open_studios_shim_delegate(:key, nil)
    end

    private

    def _open_studios_shim_event
      @_open_studios_shim_event ||= OpenStudiosEventService.current
    end

    # delegate to OpenStudiosEvent.current if there is one
    def _open_studios_shim_delegate(method, fallback)
      v = _open_studios_shim_event.send(method) if _open_studios_shim_from_db?
      v.presence || fallback
    end

    def _open_studios_shim_from_db?
      _open_studios_shim_event
    end
  end
end
