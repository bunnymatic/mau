class OpenStudiosNavigation < Navigation

  include OpenStudiosEventShim

  def items
    @items ||=
      begin
        [].tap do |osnav|
          nav_title = 'about'
          if current_open_studios_key.present?
            nav_title = OpenStudiosEvent.current.try(:for_display, true) || "Open Studios"
          end
          osnav << "<a href='#{ url_helpers.open_studios_path }' title='open studios event'>#{nav_title}</a>"
          osnav << "<a href='#{ url_helpers.artists_path(:osonly => 1) }' title='particpating artists'>participants</a>"
          osnav << "<a href='#{ url_helpers.map_artists_path(:osonly => 1) }' title='map of open studios artists'>map</a>"
        end
      end
  end

end
