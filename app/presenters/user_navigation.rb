class UserNavigation < Navigation

  attr_reader :current_user

  def initialize(user)
    @current_user = user
  end

  def current_artist
    current_user if current_user && current_user.is_a?(Artist)
  end

  def items
    @items ||=
      begin
        [].tap do |items|
          if current_artist
            items << link_to('My Profile', url_helpers.artist_path(current_artist), title: 'View My Info')
            items << link_to('My Art', url_helpers.manage_art_artist_path(current_artist), title: "Manage My Art")
            items << link_to('My Favorites', url_helpers.favorites_path(current_artist), title: "Manage My Art")
            items << link_to('My Account', url_helpers.edit_artist_path(current_artist), title: 'Edit My Info')
          else
            items << link_to('My Profile', url_helpers.user_path(current_user))
            items << link_to('My Account', url_helpers.edit_user_path(current_user))
          end
          items << link_to('sign out', url_helpers.logout_path)
        end
      end
  end


end
