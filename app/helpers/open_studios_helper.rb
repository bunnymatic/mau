module OpenStudiosHelper
  def open_studios_nav_title
    OpenStudiosEvent.current.try(:for_display, true) || "Open Studios"
  end
  def open_studios_page_title
    ["Open Studios", OpenStudiosEvent.current.try(:for_display, true)].compact.join(" - ")
  end

end

