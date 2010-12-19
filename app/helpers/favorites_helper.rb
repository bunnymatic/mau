module FavoritesHelper
  def get_image_and_path fav, sz
    img = ''
    path_finder = :user_path
    image_finder = :get_profile_image
    if fav.class.name == ArtPiece.name
      path_finder = :art_piece_path
      image_finder = :get_path
    end
    img = fav.send image_finder, sz
    path = send path_finder, fav
    [img,path]
  end

  def draw_small_favorite fav, style
    img, path = get_image_and_path fav, 'small'
    if img && path
      "<a href='#{path}'><div class='thumb'><img src='#{img}'></div><div class='name'>#{fav.get_name(true)}</div><div class='clear'></div></a>"
    end
  end

  def draw_micro_favorite fav, options
    img, path = get_image_and_path fav, 'thumb'
    xclass = options[:class] || ""
    xstyle = options[:style].blank? ? "" : "style='#{options[:style]}'"
    title = fav.get_name true
    wd, ht = fav.get_min_scaled_dimensions 24
    if img && path 
      "<li #{xstyle}><a href='#{path}' title='#{title}'><div class='thumb #{xclass}' ><img src='#{img}' title='#{title}' height='#{ht}' width='#{wd}'/></div></a></li>"
    end
  end

end

