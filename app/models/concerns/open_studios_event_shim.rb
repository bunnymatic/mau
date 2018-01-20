# frozen_string_literal: true

# shim to handle migration between oskey/oslive from conf and OpenStudiosEvent.current
module OpenStudiosEventShim
  extend ActiveSupport::Concern

  def current_open_studios_key
    @coskey ||= OpenStudiosEventService.current.try(:key)
  end

  def available_open_studios_keys
    @aoskey ||= self.class.available_open_studios_keys
  end

  module ClassMethods
    PAST_OS_EVENT_KEYS = %w[201004 201010 201104 201110 201204 201210 201304 201310 201404].freeze

    def available_open_studios_keys
      (PAST_OS_EVENT_KEYS + OpenStudiosEvent.pluck(:key)).compact.map(&:to_s).uniq.sort.select(&:present?)
    end

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
