module FavoritesHelper
  def get_favorite_image_and_path(fav, size = :small)
    title = fav.get_name
    img = nil
    path = nil
    case fav
    when ArtPiece
      img = fav.image size
      path = art_piece_path fav.id
    when MauFan
      img = asset_pack_path('media/images/default_user.svg')
    else
      img = fav.profile_image(size) || asset_pack_path('media/images/default_user.svg')
      path = user_path(fav)
    end
    [img, path, title]
  end

  def draw_micro_favorite(fav, linkless: false)
    return '' unless fav

    img, path, title = get_favorite_image_and_path fav
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
