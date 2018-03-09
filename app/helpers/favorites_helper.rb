# frozen_string_literal: false

module FavoritesHelper
  def get_favorite_image_and_path(fav, sz = :small)
    title = fav.get_name
    img = ''
    path = ''
    if fav.is_a? ArtPiece
      img = fav.path sz
      path = art_piece_path fav.id
    else
      img = fav.get_profile_image(sz) || asset_path('default_user.svg')
      path = user_path(fav)
    end
    [img, path, title]
  end

  def draw_micro_favorite(fav, linkless: false)
    return '' unless fav
    img, path, title = get_favorite_image_and_path fav, 'thumb'
    result = ''
    if img && path
      result << '<li>'
      result << "<a href='#{path}' title='#{title}'>" unless linkless
      result << "<div class='thumb' title='#{title}' style='#{background_image_style(img)}'></div>"
      result << '</a>' unless linkless
      result << '</li>'
    end
    raw result
  end
end
