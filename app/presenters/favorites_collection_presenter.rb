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
    is_current_user? ? "My Favorites" : "#{user.get_name}'s Favorites"
  end

  def empty_message
    if is_current_user?
      msg =<<-EOS
        It looks like you don't have any favorites yet.
        Go find an artist or some artwork that you like.
        You'll see this
        <span class='micro-icon heart'></span>
        around the site.  Click on it to favorite art or artists.
      EOS
      [content_tag('p', msg), content_tag('p', 'Start your search below.') ].join
    else
      "<p>This user has not favorited anything yet.</p>"
    end
  end

  def random_picks
    @random_picks ||= ArtPiece.find_random(24)
  end

  def art_pieces
    collection.select(&:is_art_piece?).map{|f| ArtPiecePresenter.new(f.to_obj)}
  end

  def artists
    collection.select(&:is_artist?).map{|f| ArtistPresenter.new(f.to_obj)}
  end

  def empty?
    !any?
  end

  def each(&block)
    collection.each(&block)
  end

end
