class OpenStudiosNavigation < Navigation

  attr_reader :current_user

  include OpenStudiosEventShim

  def initialize(view_context, user)
    @view_context = view_context
    @current_user = user
  end

  def current_artist
    current_user if current_user && current_user.is_a?(Artist)
  end

  def items
    @items ||=
      begin
        [].tap do |osnav|
          nav_title = 'about'
          if current_open_studios_key.present?
            nav_title = OpenStudiosEvent.for_display(current_open_studios_key, true)
          end
          osnav << "<a href='#{ @view_context.open_studios_path }' title='open studios event'>#{nav_title}</a>"

          osnav << "<a href='#{ @view_context.map_artists_path(:osonly => 1) }' title='map of open studios artists'>map</a>"
          osnav << "<a href='#{ @view_context.artists_path(:osonly => 1) }' title='particpating artists'>artists</a>"
        end
      end
  end

  def signup_path
    if current_artist
      @view_context.edit_artist_path(current_artist, anchor: 'events')
    else
      @view_context.login_path
    end
  end

end
