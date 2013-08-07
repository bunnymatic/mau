class FavoritesController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'

  def index
    favs = Favorite.all
    @favorites = {}
    favs.each do |f|
      fav_owner = f.user_id
      key = User.find(fav_owner).login
      unless @favorites.has_key? key
        @favorites[key] = {:artists => 0, :art_pieces => 0, :favorited => 0}
      end
      h = @favorites[key]
      case f.favoritable_type
        when 'Artist' then h[:artists] += 1
        when 'ArtPiece' then h[:art_pieces] += 1
      end
      # favorited
      if f.favoritable_type == 'Artist'
        key = User.find(f.favoritable_id).login
        unless @favorites.has_key? key
          @favorites[key] = {:artists => 0, :art_pieces => 0, :favorited => 0}
        end
        @favorites[key][:favorited] += 1
      end
    end
  end
end
