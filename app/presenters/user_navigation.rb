# frozen_string_literal: true
class UserNavigation < Navigation
  attr_reader :current_user

  def initialize(user)
    @current_user = user
  end

  def current_artist
    current_user if current_user && current_user.is_a?(Artist)
  end

  def items
    @items ||= [] + artist_nav_items + user_nav_items + [link_to('sign out', url_helpers.logout_path)]
  end

  private

  def artist_nav_items
    return [] unless current_artist
    [
      link_to('My Profile', url_helpers.artist_path(current_artist), title: 'View My Info'),
      link_to('My Art', url_helpers.manage_art_artist_path(current_artist), title: "Manage My Art"),
      link_to('My Favorites', url_helpers.favorites_path(current_artist), title: "Manage My Art"),
      link_to('My Account', url_helpers.edit_artist_path(current_artist), title: 'Edit My Info')
    ]
  end

  def user_nav_items
    return [] if current_artist
    [
      link_to('My Profile', url_helpers.user_path(current_user)),
      link_to('My Account', url_helpers.edit_user_path(current_user))
    ]
  end
end
