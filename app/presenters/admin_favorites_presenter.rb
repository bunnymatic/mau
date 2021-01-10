# frozen_string_literal: true

class AdminFavoritesPresenter
  include Enumerable

  def initialize(favorites)
    @plain_favorites = favorites
  end

  def favorites
    @favorites ||=
      begin
        processed = {}
        @plain_favorites.each do |f|
          tally_favorites(processed, f)
        end
        processed.transform_values { |entry| OpenStruct.new(entry) }
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

  def increment(type, entry)
    k = type.tableize.to_sym
    entry[k] += 1 if entry.key? k
  end

  def tally_favorites(tally, fav)
    key = fav.owner
    tally[key] ||= { artists: 0, art_pieces: 0, favorited: 0 }
    increment(fav.favoritable_type, tally[key])

    # favorited
    return unless fav.favoritable_type == 'Artist'

    key = fav.favoritable
    tally[key] ||= { artists: 0, art_pieces: 0, favorited: 0 }
    tally[key][:favorited] += 1
  end

  def sum_column(col_name)
    favorites.values.sum { |v| v[col_name].to_i }
  end
end
