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
          if current_open_studios_key
            osnav << "<a href='#{ @view_context.open_studios_path }' title='open studios event'>event details</a>"
            osnav << "<a href='#{ @view_context.artists_path(:osonly => 1) }' title='particpating artists'>participating artists</a>"
            osnav << "<a href='#{ @view_context.map_artists_path(:osonly => 1) }' title='map of open studios artists'>os map</a>"
            osnav << "<a href='#{signup_path}'>artist sign up</a>"
            osnav << "<a href='#{ @view_context.artist_resources_path }' title='artists resources'>artist resources</a>"
          end
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
