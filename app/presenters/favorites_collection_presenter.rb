# frozen_string_literal: true

class FavoritesCollectionPresenter < ViewPresenter
  attr_reader :user, :current_user

  include Enumerable

  def initialize(user, current_user = nil)
    @user = user
    @current_user = current_user
  end

  def current_user_is_user?
    current_user && (user == current_user)
  end

  def title
    if current_user_is_user?
      safe_join([(link_to 'My', url_helpers.user_path(current_user)) + ' Favorites'])
    else
      safe_join([(link_to "#{user.get_name}'s", url_helpers.user_path(user)) + ' Favorites'])
    end
  end

  def empty_message
    if current_user_is_user?
      msg = <<-MSG
        It looks like you don't have any favorites yet.
        Go find an artist or some artwork that you like.
        You'll see this
        <span class='fa fa-heart'></span>
        around the site.  Click on it to favorite art or artists.
      MSG
      raw [tag.p(raw(msg)), tag.p('Start your search below.')].join
    else
      raw '<p>This user has not favorited anything yet.</p>'
    end
  end

  def random_picks
    @random_picks ||= ArtPiece.find_random(24)
  end

  def art_pieces
    user.favorites.art_pieces.includes(favoritable: [
                                         :medium,
                                         { artist: :open_studios_events },
                                       ]).map do |favorite|
      piece = favorite.favoritable
      valid_artist = piece.try(:artist).try(&:active?)
      ArtPieceFavoritePresenter.new(favorite) if valid_artist
    end.compact
  end

  def artists
    user.favorites.artists.includes(favoritable: [
                                      :open_studios_events,
                                      :artist_info,
                                      { art_pieces: :medium },
                                    ]).map do |favorite|
      artist = favorite.favoritable
      artist.representative_piece && ArtistFavoritePresenter.new(favorite) if artist.active?
    end.compact
  end

  def empty?
    !@user.favorites.exists?
  end

  def each(&block)
    @user.favorites.each(&block)
  end
end
