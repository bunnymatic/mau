module OpenStudiosHelper
  def open_studios_nav_title
    OpenStudiosEventService.current.try(:for_display, month_first: true) || 'Open Studios'
  end

  def open_studios_page_title
    ['Open Studios', OpenStudiosEventService.current.try(:for_display, month_first: true)].compact.join(' - ')
  end
end
