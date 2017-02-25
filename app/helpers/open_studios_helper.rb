# frozen_string_literal: true
module OpenStudiosHelper
  def open_studios_nav_title
    OpenStudiosEventService.current.try(:for_display, true) || "Open Studios"
  end

  def open_studios_page_title
    ["Open Studios", OpenStudiosEventService.current.try(:for_display, true)].compact.join(" - ")
  end
end

