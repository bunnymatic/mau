class UserNavigation

  attr_reader :current_user

  def initialize(view_context, user)
    @view_context = view_context
    @current_user = user
  end

  def current_artist
    current_user if current_user && current_user.is_a?(Artist)
  end

  def mypath
    if current_artist
      current_artist
    else
      @view_context.user_path(current_user)
    end
  end

  def navitems
    @navitems ||=
      begin
        [].tap do |navitems|
          if current_artist
            navitems << link_to('edit my page', @view_context.edit_artist_path(current_artist))
            navitems << link_to('add art', @view_context.new_artist_art_piece_path(current_artist))
            navitems << link_to('arrange art', @view_context.arrange_art_artists_path)
            navitems << link_to('delete art', @view_context.delete_art_artists_path)
            navitems << link_to('plug your art show', @view_context.new_event_path, :class => 'list_your_show_dropdown')

            navitems << link_to("<i class='ico micro-icon ico-heart'></i> my favorites".html_safe, @view_context.favorites_user_path(current_user))
            navitems << link_to('resources', @view_context.artist_resources_path, :title => 'artists\' resources')
            navitems << link_to('my qrcode', @view_context.qrcode_artist_path(current_artist), :target => '_blank')
          else
            navitems << "<a href='#{@view_context.edit_user_path(current_user) }'>edit my page</a>"
            navitems << "<a href='#{@view_context.favorites_user_path current_user}'><span class='heart'>&hearts;</span> my favorites</a>"
          end
        end
      end
  end

  private
  def link_to(*args)
    @view_context.link_to(*args)
  end

end
