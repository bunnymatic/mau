module FavoritesHelper
  def draw_favorite fav, style
    img = ''
    [:get_profile_image, :get_path].each do |method|
      if fav.respond_to? method
        img = fav.send method, 'small'
        break
      end
    end
    if img
      "<li><img src='" + img + "'></li>"
    end
  end
end
