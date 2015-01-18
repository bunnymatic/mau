class UserNavigation < Navigation

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

  def items
    @items ||=
      begin
        [].tap do |items|
          if current_artist
            items << link_to('view profile', @view_context.artist_path(current_artist))
            items << link_to('edit profile', @view_context.edit_artist_path(current_artist))
            items << link_to('add art', @view_context.new_artist_art_piece_path(current_artist))
            items << link_to('manage art', @view_context.manage_art_artist_path(current_artist))


            # items << link_to("<i class='fa fa-icon fa-heart'></i> favorites".html_safe, @view_context.user_favorites_path(current_user))
            # items << link_to('resources', @view_context.artist_resources_path, :title => 'artists\' resources')
            # items << link_to('qrcode', @view_context.qrcode_artist_path(current_artist), :target => '_blank')
            # items << link_to('having a show?', @view_context.new_event_path, :class => 'list_your_show_dropdown')
          else
            items << link_to('view profile', @view_context.user_path(current_user))
            items << link_to('edit profile', @view_context.edit_user_path(current_user))
          end
          items << link_to('sign out', @view_context.logout_path)
        end
      end
  end

  private
  def link_to(*args)
    @view_context.link_to(*args)
  end

end
