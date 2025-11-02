class AdminFavoritesPresenter
  include Enumerable

  class FavoriteStats
    include ActiveModel::Model

    attr_accessor :artists, :art_pieces, :favorited

    LUT = {
      Artist: :artists,
      ArtPiece: :art_pieces,
      Favorited: :favorited,
    }.freeze

    def initialize
      @artists = 0
      @art_pieces = 0
      @favorited = 0
    end

    def increment(type)
      key = LUT[type.to_sym]
      cur = send(key)
      send(:"#{key}=", cur + 1)
    end
  end

  def initialize(favorites)
    @plain_favorites = favorites
  end

  def favorites
    @favorites ||=
      @plain_favorites.each_with_object({}) do |fav, tally|
        key = fav.owner
        tally[key] ||= FavoriteStats.new
        tally[key].increment(fav.favoritable_type)

        next unless fav.favoritable_type == Artist.name

        # handle favorited
        key = fav.favoritable
        tally[key] ||= FavoriteStats.new
        tally[key].increment('Favorited')
      end
  end

  def total_artists
    sum_column(:artists)
  end

  def total_art_pieces
    sum_column(:art_pieces)
  end

  def total_favorited_users
    sum_column(:favorited)
  end

  def each(&)
    favorites.each(&)
  end

  private

  def sum_column(col_name)
    favorites.values.sum { |v| v.send(col_name).to_i }
  end
end
