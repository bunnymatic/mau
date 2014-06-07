class AdminFavoritesPresenter

  include Enumerable

  def initialize(favorites)
    @plain_favorites = favorites
  end

  def favorites
    @processed ||=
      begin
        processed = {}
        @plain_favorites.each do |f|
          tally_favorites(processed, f)
        end
        Hash[ processed.map{|key, entry| [key, OpenStruct.new(entry)] } ]
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

  def each(&block)
    favorites.each(&block)
  end

  private
  def user_key(fav)
    User.find(fav.user_id)
  end

  def increment(type, entry)
    k = type.tableize.to_sym
    entry[k] += 1 if entry.has_key? k
  end

  def tally_favorites(tally, fav)
    key = user_key(fav)
    tally[key] ||= {:artists => 0, :art_pieces => 0, :favorited => 0}
    increment(fav.favoritable_type, tally[key])

    # favorited
    if fav.favoritable_type == 'Artist'
      key = User.find(fav.favoritable_id)
      tally[key] ||= {:artists => 0, :art_pieces => 0, :favorited => 0}
      tally[key][:favorited] += 1
    end
  end

  private
  def sum_column(col_name)
    favorites.values.map{|v| v[col_name].to_i}.sum
  end

end
