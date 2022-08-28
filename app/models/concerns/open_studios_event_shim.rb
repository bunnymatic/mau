# shim to handle migration between oskey/oslive from conf and OpenStudiosEvent.current
module OpenStudiosEventShim
  extend ActiveSupport::Concern

  def current_open_studios_key
    @current_open_studios_key ||= OpenStudiosEventService.current.try(:key)
  end

  module ClassMethods
    def current_open_studios_key
      OpenStudiosEventService.current.try(:key)
    end
  end
end
