# frozen_string_literal: true
class FavoritesCollectionPresenter < ViewPresenter
  attr_reader :user, :collection, :current_user

  include Enumerable

  def initialize(favorites, user, current_user = nil)
    @collection = favorites
    @user = user
    @current_user = current_user
  end

  def is_current_user?
    current_user && (user == current_user)
  end

  def title
    if is_current_user?
      ((link_to "My", url_helpers.user_path(current_user)) + " Favorites").html_safe
    else
      ((link_to "#{user.get_name}'s", url_helpers.user_path(user)) + " Favorites").html_safe
    end
  end

  def empty_message
    if is_current_user?
      msg =<<-EOS
        It looks like you don't have any favorites yet.
        Go find an artist or some artwork that you like.
        You'll see this
        <span class='fa fa-heart'></span>
        around the site.  Click on it to favorite art or artists.
      EOS
      [content_tag('p', msg.html_safe), content_tag('p', 'Start your search below.') ].join
    else
      "<p>This user has not favorited anything yet.</p>"
    end
  end

  def random_picks
    @random_picks ||= ArtPiece.find_random(24)
  end

  def art_pieces
    collection.select(&:is_art_piece?).map do |f|
      art_piece = f.to_obj
      valid_artist = art_piece.try(:artist).try(&:active?)
      ArtPieceFavoritePresenter.new(f) if valid_artist
    end.compact
  end

  def artists
    collection.select(&:is_artist?).map do |f|
      o = f.to_obj
      o.representative_piece && ArtistFavoritePresenter.new(f) if o.active?
    end.compact
  end

  def empty?
    !any?
  end

  def each(&block)
    collection.each(&block)
  end
end
