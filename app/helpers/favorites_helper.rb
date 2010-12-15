module FavoritesHelper
  def draw_favorite fav, style
    img = ''
    path_finder = :artist_path
    image_finder = :get_profile_image
    if fav.class.name == ArtPiece.name
      path_finder = :art_piece_path
      image_finder = :get_path
    end
    img = fav.send image_finder, 'small'
    path = send path_finder, fav
    if img && path
      "<a href='#{path}'><div class='thumb'><img src='#{img}'></div><div class='name'>#{fav.get_name(true)}</div><div class='clear'></div></a>"
    end
    
  end

end
