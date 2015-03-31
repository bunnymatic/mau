module FavoritesHelper
  def get_image_and_path fav, sz
    img = ''
    path_finder = :user_path
    image_finder = :get_profile_image
    if fav.is_a? ArtPiece
      img = fav.get_path sz
      path = art_piece_path fav.id
    else
      img = fav.send image_finder, sz
      path = send path_finder, fav
    end
    [img,path]
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
      result << "<div class='thumb #{xclass}' title='#{title}' style='background-image: url(#{img})'></div>"
      result << "</a>" unless options[:linkless]
      result << "</li>"
    end
    result.html_safe
  end
end



