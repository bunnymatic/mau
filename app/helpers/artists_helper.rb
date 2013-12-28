module ArtistsHelper
  include MauUrlHelpers
  include HtmlHelper

  def has_links(artist)
    Artist::KEYED_LINKS.each do |kk, disp|
      if artist[kk] and !artist[kk].empty?
        return true
      end
    end
    return false
  end

  def bio_html(bio)
    biostr = ""
    bio.split("\n").each do |line|
      biostr += (html_encode(line) + "<br/>")
    end
    biostr.html_safe
  end

  # get info for google map info window as html
  # if you have lat lon, include it for directions link
  def get_map_info(artist)
    html = '<style type="text/css">._mau1 { color: #222222; font-size: x-small; } '+
      '_mau1 a{ color: #ff2222; }</style><div class="_mau1">'
    ap = artist.representative_piece
    aname = artist.get_name(true)
    img = ''
    # tried to add title to these links, but it seems google maps
    # is too smart for that.
    if (ap && ap.is_a?(ArtPiece))
      img = "<a class='lkdark' href='%s'><img src='%s'/></a>" % [ artist_path(artist), ap.get_path('thumb') ]
      html += '<div class="_mau1" style="float:right;">%s</div>' % img
    end
    address = artist.address_hash
    name = "<a class='lkdark' href='%s'>%s</a>" % [ artist_path(artist), aname ]
    street = address[:parsed][:street]
    if artist.studio_id.nil? or artist.studio_id == 0
      html += "%s<div>%s</div>" % [ name, street ]
    else
      html += "%s<div>%s</div><div>%s</div>" % [name, artist.studio.name, street]
    end
    html += '<div style="clear"></div>'
    html += "</div>"
  end

  def for_mobile_list(artist)
    artist.get_name true
  end

end
