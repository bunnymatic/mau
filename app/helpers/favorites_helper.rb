# frozen_string_literal: false
module FavoritesHelper
  def get_favorite_image_and_path(fav, sz = :small)
    title = fav.get_name
    img = ''
    path = ''
    if fav.is_a? ArtPiece
      img = fav.get_path sz
      path = art_piece_path fav.id
    else
      img = fav.get_profile_image(sz) || asset_path('default_user.svg')
      path = user_path(fav)
    end
    [img, path, title]
  end

  def draw_micro_favorite(fav, options = nil)
    options ||= {}
    return '' unless fav
    img, path, title = get_favorite_image_and_path fav, 'thumb'
    xclass = options[:class] || ''
    xstyle = options[:style].blank? ? '' : "style='#{options[:style]}'"
    result = ''
    if img && path
      result << "<li #{xstyle}>"
      result << "<a href='#{path}' title='#{title}'>" unless options[:linkless]
      result << "<div class='thumb #{xclass}' title='#{title}' style='#{background_image_style(img)}'></div>"
      result << '</a>' unless options[:linkless]
      result << '</li>'
    end
    result.html_safe
  end
end
