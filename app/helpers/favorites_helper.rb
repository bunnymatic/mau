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

  def draw_small_favorite fav, options=nil
    options ||= {}
    xstyle = options[:style]
    img, path = get_image_and_path fav, 'small'
    del_btn = ''
    if options[:is_owner] == true
      del_btn = "<div title='remove favorite' class='del-btn micro-icon trash' fav_type='#{fav.class.name}' fav_id='#{fav.id}'></div>"
    end
    if img && path
      "<li><div class='thumb'><a href='#{path}'><img src='#{img}'></a></div><div class='name'><a href='#{path}'>#{fav.get_name(true)}</a>#{del_btn}</div><div class='clear'></div></li>"
    end
  end

  def draw_micro_favorite fav, options=nil
    options ||= {}
    img, path = get_image_and_path fav, 'thumb'
    xclass = options[:class] || ""
    xstyle = options[:style].blank? ? "" : "style='#{options[:style]}'"
    title = fav.get_name true
    wd, ht = fav.get_min_scaled_dimensions 24
    if img && path 
      "<li #{xstyle}><a href='#{path}' title='#{title}'><div class='thumb #{xclass}' ><img src='#{img}' title='#{title}' height='#{ht}' width='#{wd}'/></div></a></li>"
    end
  end
  
  def draw_thumb_widget fav, options=nil
    options ||= {}
    if fav.class == Artist
      draw_artist_widget fav, options
    else
      draw_art_piece_widget fav, options
    end
  end

  def draw_art_piece_widget fav, options
    img, path = get_image_and_path fav, 'thumb'
    title = fav.get_name true
    if img && path 
<<THUMB
   <div class="artpiece-thumb">
     <div class="search-thumb-art thumb">
        <a href="#{path}"><img border=0 src="#{img}" /></a>
     </div>
     <div class="search-thumb-info">
        <a href="#{path}">#{title}</a> by <a href="#{artist_path(fav.artist)}">#{fav.artist.get_name true}</a>
     </div>
   </div>
THUMB
    end
  end
  def draw_artist_widget fav, options
    img, path = get_image_and_path fav, 'thumb'
    title = fav.get_name true
    from_studio = ''
    if fav.studio 
      from_studio = "from <a href='#{studio_path(fav.studio)}'>#{fav.studio.get_name true}</a>"
    end
    if img && path 
<<THUMB
   <div class="artpiece-thumb">
     <div class="search-thumb-art thumb">
        <a href="#{path}"><img border=0 src="#{img}" /></a>
     </div>
     <div class="search-thumb-info">
       <div><a href="#{path}">#{title}<a> #{from_studio}</div>
     </div>
   </div>
THUMB
    end
  end
end



