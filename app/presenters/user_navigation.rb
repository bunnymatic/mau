class UserNavigation < Navigation

  attr_reader :current_user

  def initialize(user)
    @current_user = user
  end

  def current_artist
    current_user if current_user && current_user.is_a?(Artist)
  end

  def mypath
    if current_artist
      current_artist
    else
      url_helpers.user_path(current_user)
    end
  end

  def items
    @items ||=
      begin
        [].tap do |items|
          if current_artist
            items << link_to('view profile', url_helpers.artist_path(current_artist), title: 'View My Profile')
            items << link_to('edit profile', url_helpers.edit_artist_path(current_artist), title: 'Edit My Profile')
            items << link_to('add art', url_helpers.new_artist_art_piece_path(current_artist), title: "Add Art")
            items << link_to('manage art', url_helpers.manage_art_artist_path(current_artist), title: "Manage My Art")

          else
            items << link_to('view profile', url_helpers.user_path(current_user))
            items << link_to('edit profile', url_helpers.edit_user_path(current_user))
          end
          items << link_to('sign out', url_helpers.logout_path)
        end
      end
  end


end
