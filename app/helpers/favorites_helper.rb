module FavoritesHelper
  def get_image_and_path fav, sz
    img = ''
    path_finder = :user_path
    image_finder = :get_profile_image
    if fav.is_a? ArtPiece
      img = fav.get_path sz
      path = artist_art_piece_path fav.artist.id, fav.id
    else
      img = fav.send image_finder, sz
      path = send path_finder, fav
    end
    [img,path]
  end

  def draw_small_favorite fav, options=nil
    options ||= {}
    xstyle = options[:style]
    img, path = get_image_and_path fav, 'small'
    del_btn = ''
    if options[:is_owner] == true
      del_btn = ("<div title='remove favorite' class='del-btn micro-icon trash' "+
        "fav-type='#{fav.class.name}' fav-id='#{fav.id}'></div>").html_safe
    end
    if img && path
      ("<li><div class='thumb'><a href='#{path}'><img src='#{img}'></a></div>"+
        "<div class='name'><a href='#{path}'>#{fav.get_name(true)}</a>#{del_btn}</div>"+
        "<div class='clear'></div></li>").html_safe
    end
  end

  def draw_micro_favorite fav, options=nil
    options ||= {}
    img, path = get_image_and_path fav, 'thumb'
    xclass = options[:class] || ""
    xstyle = options[:style].blank? ? "" : "style='#{options[:style]}'"
    title = fav.get_name true
    wd, ht = fav.get_min_scaled_dimensions 24
    result = ""
    if img && path
      result << "<li #{xstyle}>"
      result << "<a href='#{path}' title='#{title}'>" unless options[:linkless]
      result << "<div class='thumb #{xclass}' ><img src='#{img}' title='#{title}' height='#{ht}' width='#{wd}'/></div>"
      result << "</a>" unless options[:linkless]
      result << "</li>"
    end
    result.html_safe
  end
end



